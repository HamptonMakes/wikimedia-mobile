#include <ruby.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <locale.h>
#include <sqlite3.h>

#define ID_CONST_GET rb_intern("const_get")
#define ID_PATH rb_intern("path")
#define ID_NEW rb_intern("new")
#define ID_ESCAPE rb_intern("escape_sql")

#define RUBY_STRING(char_ptr) rb_str_new2(char_ptr)
#define TAINTED_STRING(name) rb_tainted_str_new2(name)
#define CONST_GET(scope, constant) (rb_funcall(scope, ID_CONST_GET, 1, rb_str_new2(constant)))
#define SQLITE3_CLASS(klass, parent) (rb_define_class_under(mSqlite3, klass, parent))

#define TRUE_CLASS CONST_GET(rb_mKernel, "TrueClass")

#ifndef RSTRING_PTR
#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif

#ifndef RSTRING_LEN
#define RSTRING_LEN(s) (RSTRING(s)->len)
#endif

#ifndef RARRAY_LEN
#define RARRAY_LEN(a) RARRAY(a)->len
#endif

#ifdef _WIN32
#define do_int64 signed __int64
#else
#define do_int64 signed long long int
#endif

// To store rb_intern values
static ID ID_NEW_DATE;
static ID ID_LOGGER;
static ID ID_DEBUG;
static ID ID_LEVEL;

static VALUE mDO;
static VALUE cDO_Quoting;
static VALUE cDO_Connection;
static VALUE cDO_Command;
static VALUE cDO_Result;
static VALUE cDO_Reader;

static VALUE rb_cDate;
static VALUE rb_cDateTime;

#ifndef RUBY_19_COMPATIBILITY
static VALUE rb_cRational;
#endif

static VALUE rb_cBigDecimal;

static VALUE mSqlite3;
static VALUE cConnection;
static VALUE cCommand;
static VALUE cResult;
static VALUE cReader;

static VALUE eSqlite3Error;


/****** Typecasting ******/
static VALUE native_typecast(sqlite3_value *value, int type) {
	VALUE ruby_value = Qnil;

	switch(type) {
		case SQLITE_NULL: {
			ruby_value = Qnil;
			break;
		}
		case SQLITE_INTEGER: {
			ruby_value = LL2NUM(sqlite3_value_int64(value));
			break;
		}
		case SQLITE3_TEXT: {
			ruby_value = rb_str_new2((char*)sqlite3_value_text(value));
			break;
		}
		case SQLITE_FLOAT: {
			ruby_value = rb_float_new(sqlite3_value_double(value));
			break;
		}
	}
	return ruby_value;
}

// Find the greatest common denominator and reduce the provided numerator and denominator.
// This replaces calles to Rational.reduce! which does the same thing, but really slowly.
static void reduce( do_int64 *numerator, do_int64 *denominator ) {
	do_int64 a, b, c = 0;
	a = *numerator;
	b = *denominator;
	while ( a != 0 ) {
		c = a; a = b % a; b = c;
	}
	*numerator = *numerator / b;
	*denominator = *denominator / b;
}

// Generate the date integer which Date.civil_to_jd returns
static int jd_from_date(int year, int month, int day) {
	int a, b;
	if ( month <= 2 ) {
		year -= 1;
		month += 12;
	}
	a = year / 100;
	b = 2 - a + (a / 4);
	return floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + b - 1524;
}

static void data_objects_debug(VALUE string) {
	VALUE logger = rb_funcall(mSqlite3, ID_LOGGER, 0);
	int log_level = NUM2INT(rb_funcall(logger, ID_LEVEL, 0));

	if (0 == log_level) {
		rb_funcall(logger, ID_DEBUG, 1, string);
	}
}

static VALUE parse_date(char *date) {
	int year, month, day;
	int jd, ajd;
	VALUE rational;

	sscanf(date, "%4d-%2d-%2d", &year, &month, &day);

	jd = jd_from_date(year, month, day);

	// Math from Date.jd_to_ajd
	ajd = jd * 2 - 1;
	rational = rb_funcall(rb_cRational, rb_intern("new!"), 2, INT2NUM(ajd), INT2NUM(2));
	return rb_funcall(rb_cDate, ID_NEW_DATE, 3, rational, INT2NUM(0), INT2NUM(2299161));
}

// Creates a Rational for use as a Timezone offset to be passed to DateTime.new!
static VALUE seconds_to_offset(do_int64 num) {
	do_int64 den = 86400;
	reduce(&num, &den);
	return rb_funcall(rb_cRational, rb_intern("new!"), 2, rb_ll2inum(num), rb_ll2inum(den));
}

static VALUE timezone_to_offset(int hour_offset, int minute_offset) {
	do_int64 seconds = 0;

	seconds += hour_offset * 3600;
	seconds += minute_offset * 60;

	return seconds_to_offset(seconds);
}

static VALUE parse_date_time(char *date) {
	VALUE ajd, offset;

	int year, month, day, hour, min, sec, usec, hour_offset, minute_offset;
	int jd;
	do_int64 num, den;

	long int gmt_offset;
	int is_dst;

	time_t rawtime;
	struct tm * timeinfo;

	int tokens_read, max_tokens;

  if ( strcmp(date, "") == 0 ) {
    return Qnil;
  }

	if (0 != strchr(date, '.')) {
		// This is a datetime with sub-second precision
		tokens_read = sscanf(date, "%4d-%2d-%2d%*c%2d:%2d:%2d.%d%3d:%2d", &year, &month, &day, &hour, &min, &sec, &usec, &hour_offset, &minute_offset);
		max_tokens = 9;
	} else {
		// This is a datetime second precision
		tokens_read = sscanf(date, "%4d-%2d-%2d%*c%2d:%2d:%2d%3d:%2d", &year, &month, &day, &hour, &min, &sec, &hour_offset, &minute_offset);
		max_tokens = 8;
	}

	if (max_tokens == tokens_read) {
		// We read the Date, Time, and Timezone info
		minute_offset *= hour_offset < 0 ? -1 : 1;
	} else if ((max_tokens - 1) == tokens_read) {
		// We read the Date and Time, but no Minute Offset
		minute_offset = 0;
	} else if (tokens_read == 3) {
		return parse_date(date);
	} else if (tokens_read >= (max_tokens - 3)) {
		// We read the Date and Time, default to the current locale's offset

		// Get localtime
		time(&rawtime);
		timeinfo = localtime(&rawtime);

		is_dst = timeinfo->tm_isdst * 3600;

		// Reset to GM Time
		timeinfo = gmtime(&rawtime);

		gmt_offset = mktime(timeinfo) - rawtime;

		if ( is_dst > 0 )
			gmt_offset -= is_dst;

		hour_offset = -(gmt_offset / 3600);
		minute_offset = -(gmt_offset % 3600 / 60);

	} else {
		// Something went terribly wrong
		rb_raise(eSqlite3Error, "Couldn't parse date: %s", date);
	}

	jd = jd_from_date(year, month, day);

	// Generate ajd with fractional days for the time
	// Extracted from Date#jd_to_ajd, Date#day_fraction_to_time, and Rational#+ and #-
	num = (hour * 1440) + (min * 24);

	// Modify the numerator so when we apply the timezone everything works out
	num -= (hour_offset * 1440) + (minute_offset * 24);

	den = (24 * 1440);
	reduce(&num, &den);

	num = (num * 86400) + (sec * den);
	den = den * 86400;
	reduce(&num, &den);

	num = (jd * den) + num;

	num = num * 2;
	num = num - den;
	den = den * 2;

	reduce(&num, &den);

	ajd = rb_funcall(rb_cRational, rb_intern("new!"), 2, rb_ull2inum(num), rb_ull2inum(den));
	offset = timezone_to_offset(hour_offset, minute_offset);

	return rb_funcall(rb_cDateTime, ID_NEW_DATE, 3, ajd, offset, INT2NUM(2299161));
}

static VALUE parse_time(char *date) {

	int year, month, day, hour, min, sec, usec;
	char subsec[7];

	if (0 != strchr(date, '.')) {
		// right padding usec with 0. e.g. '012' will become 12000 microsecond, since Time#local use microsecond
	  sscanf(date, "%4d-%2d-%2d %2d:%2d:%2d.%s", &year, &month, &day, &hour, &min, &sec, subsec);
		sscanf(subsec, "%d", &usec);
	} else {
		sscanf(date, "%4d-%2d-%2d %2d:%2d:%2d", &year, &month, &day, &hour, &min, &sec);
		usec = 0;
	}

	return rb_funcall(rb_cTime, rb_intern("local"), 7, INT2NUM(year), INT2NUM(month), INT2NUM(day), INT2NUM(hour), INT2NUM(min), INT2NUM(sec), INT2NUM(usec));
}

static VALUE ruby_typecast(sqlite3_value *value, char *type, int original_type) {
	VALUE ruby_value = Qnil;

	if ( original_type == SQLITE_NULL ) {
		return ruby_value;
	} else if ( strcmp(type, "Class") == 0) {
    ruby_value = rb_funcall(mDO, rb_intern("find_const"), 1, TAINTED_STRING((char*)sqlite3_value_text(value)));
  } else if ( strcmp(type, "Object") == 0 ) {
		ruby_value = rb_marshal_load(rb_str_new2((char*)sqlite3_value_text(value)));
	} else if ( strcmp(type, "TrueClass") == 0 ) {
		ruby_value = strcmp((char*)sqlite3_value_text(value), "t") == 0 ? Qtrue : Qfalse;
	} else if ( strcmp(type, "Integer") == 0 || strcmp(type, "Fixnum") == 0 || strcmp(type, "Bignum") == 0 ) {
		ruby_value = LL2NUM(sqlite3_value_int64(value));
	} else if ( strcmp(type, "BigDecimal") == 0 ) {
		ruby_value = rb_funcall(rb_cBigDecimal, ID_NEW, 1, TAINTED_STRING((char*)sqlite3_value_text(value)));
	} else if ( strcmp(type, "String") == 0 ) {
		ruby_value = TAINTED_STRING((char*)sqlite3_value_text(value));
	} else if ( strcmp(type, "Float") == 0 ) {
		ruby_value = rb_float_new(sqlite3_value_double(value));
	} else if ( strcmp(type, "Date") == 0 ) {
		ruby_value = parse_date((char*)sqlite3_value_text(value));
	} else if ( strcmp(type, "DateTime") == 0 ) {
		ruby_value = parse_date_time((char*)sqlite3_value_text(value));
	} else if ( strcmp(type, "Time") == 0 ) {
		ruby_value = parse_time((char*)sqlite3_value_text(value));
	}

	return ruby_value;
}


/****** Public API ******/

static VALUE cConnection_initialize(VALUE self, VALUE uri) {
	int ret;
	VALUE path;
	sqlite3 *db;

	path = rb_funcall(uri, ID_PATH, 0);
	ret = sqlite3_open(StringValuePtr(path), &db);

	if ( ret != SQLITE_OK ) {
		rb_raise(eSqlite3Error, sqlite3_errmsg(db));
	}

	rb_iv_set(self, "@uri", uri);
	rb_iv_set(self, "@connection", Data_Wrap_Struct(rb_cObject, 0, 0, db));

	return Qtrue;
}

static VALUE cConnection_dispose(VALUE self) {
	sqlite3 *db;
	Data_Get_Struct(rb_iv_get(self, "@connection"), sqlite3, db);
	sqlite3_close(db);
	return Qtrue;
}

static VALUE cCommand_set_types(VALUE self, VALUE array) {
	rb_iv_set(self, "@field_types", array);
	return array;
}

static VALUE cCommand_quote_boolean(VALUE self, VALUE value) {
	return TAINTED_STRING(value == Qtrue ? "'t'" : "'f'");
}

static VALUE cCommand_quote_string(VALUE self, VALUE string) {
	const char *source = StringValuePtr(string);
	char *escaped_with_quotes;

	// Wrap the escaped string in single-quotes, this is DO's convention
	escaped_with_quotes = sqlite3_mprintf("%Q", source);

	return TAINTED_STRING(escaped_with_quotes);
}

static VALUE build_query_from_args(VALUE klass, int count, VALUE *args) {
	VALUE query = rb_iv_get(klass, "@text");
	if ( count > 0 ) {
		int i;
		VALUE array = rb_ary_new();
		for ( i = 0; i < count; i++) {
			rb_ary_push(array, (VALUE)args[i]);
		}
		query = rb_funcall(klass, ID_ESCAPE, 1, array);
	}
	return query;
}

static VALUE cCommand_execute_non_query(int argc, VALUE *argv, VALUE self) {
	sqlite3 *db;
	char *error_message;
	int status;
	int affected_rows;
	int insert_id;
	VALUE conn_obj;
	VALUE query;

	query = build_query_from_args(self, argc, argv);
	data_objects_debug(query);

	conn_obj = rb_iv_get(self, "@connection");
	Data_Get_Struct(rb_iv_get(conn_obj, "@connection"), sqlite3, db);

	status = sqlite3_exec(db, StringValuePtr(query), 0, 0, &error_message);

	if ( status != SQLITE_OK ) {
		rb_raise(eSqlite3Error, sqlite3_errmsg(db));
	}

	affected_rows = sqlite3_changes(db);
	insert_id = sqlite3_last_insert_rowid(db);

	return rb_funcall(cResult, ID_NEW, 3, self, INT2NUM(affected_rows), INT2NUM(insert_id));
}

static VALUE cCommand_execute_reader(int argc, VALUE *argv, VALUE self) {
	sqlite3 *db;
	sqlite3_stmt *sqlite3_reader;
	int status;
	int field_count;
	int i;
	VALUE reader;
	VALUE conn_obj;
	VALUE query;
	VALUE field_names, field_types;

	conn_obj = rb_iv_get(self, "@connection");
	Data_Get_Struct(rb_iv_get(conn_obj, "@connection"), sqlite3, db);

	query = build_query_from_args(self, argc, argv);
	
	data_objects_debug(query);

	status = sqlite3_prepare_v2(db, StringValuePtr(query), -1, &sqlite3_reader, 0);

	if ( status != SQLITE_OK ) {
		rb_raise(eSqlite3Error, sqlite3_errmsg(db));
	}

	field_count = sqlite3_column_count(sqlite3_reader);

	reader = rb_funcall(cReader, ID_NEW, 0);
	rb_iv_set(reader, "@reader", Data_Wrap_Struct(rb_cObject, 0, 0, sqlite3_reader));
	rb_iv_set(reader, "@field_count", INT2NUM(field_count));

	field_names = rb_ary_new();
	field_types = rb_iv_get(self, "@field_types");

	// if ( field_types == Qnil ) {
	// 	field_types = rb_ary_new();
	// }

	if ( field_types == Qnil || 0 == RARRAY_LEN(field_types) ) {
		field_types = rb_ary_new();
	} else if (RARRAY_LEN(field_types) != field_count) {
		// Whoops...  wrong number of types passed to set_types.  Close the reader and raise
		// and error
		rb_funcall(reader, rb_intern("close"), 0);
		rb_raise(eSqlite3Error, "Field-count mismatch. Expected %ld fields, but the query yielded %d", RARRAY_LEN(field_types), field_count);
	}



	for ( i = 0; i < field_count; i++ ) {
		rb_ary_push(field_names, rb_str_new2((char *)sqlite3_column_name(sqlite3_reader, i)));
	}

	rb_iv_set(reader, "@fields", field_names);
	rb_iv_set(reader, "@field_types", field_types);

	return reader;
}

static VALUE cReader_close(VALUE self) {
	VALUE reader_obj = rb_iv_get(self, "@reader");

	if ( reader_obj != Qnil ) {
		sqlite3_stmt *reader;
		Data_Get_Struct(reader_obj, sqlite3_stmt, reader);
		sqlite3_finalize(reader);
		rb_iv_set(self, "@reader", Qnil);
		return Qtrue;
	}
	else {
		return Qfalse;
	}
}

static VALUE cReader_next(VALUE self) {
	sqlite3_stmt *reader;
	int field_count;
	int result;
	int i;
	int ft_length;
	VALUE arr = rb_ary_new();
	VALUE field_types;
	VALUE value;

	Data_Get_Struct(rb_iv_get(self, "@reader"), sqlite3_stmt, reader);
	field_count = NUM2INT(rb_iv_get(self, "@field_count"));

	field_types = rb_iv_get(self, "@field_types");
	ft_length = RARRAY_LEN(field_types);

	result = sqlite3_step(reader);

	rb_iv_set(self, "@state", INT2NUM(result));

	if ( result != SQLITE_ROW ) {
		return Qnil;
	}

	for ( i = 0; i < field_count; i++ ) {
		if ( ft_length == 0 ) {
			value = native_typecast(sqlite3_column_value(reader, i), sqlite3_column_type(reader, i));
		}
		else {
			value = ruby_typecast(sqlite3_column_value(reader, i), rb_class2name(RARRAY_PTR(field_types)[i]), sqlite3_column_type(reader, i));
		}
		rb_ary_push(arr, value);
	}

	rb_iv_set(self, "@values", arr);

	return Qtrue;
}

static VALUE cReader_values(VALUE self) {
	VALUE state = rb_iv_get(self, "@state");
	if ( state == Qnil || NUM2INT(state) != SQLITE_ROW ) {
		rb_raise(eSqlite3Error, "Reader is not initialized");
	}
	else {
		return rb_iv_get(self, "@values");
	}
}

static VALUE cReader_fields(VALUE self) {
	return rb_iv_get(self, "@fields");
}

void Init_do_sqlite3_ext() {

	rb_require("rubygems");
	rb_require("bigdecimal");
	rb_require("date");

	// Get references classes needed for Date/Time parsing
	rb_cDate = CONST_GET(rb_mKernel, "Date");
	rb_cDateTime = CONST_GET(rb_mKernel, "DateTime");
	rb_cTime = CONST_GET(rb_mKernel, "Time");
	rb_cRational = CONST_GET(rb_mKernel, "Rational");
	rb_cBigDecimal = CONST_GET(rb_mKernel, "BigDecimal");

	rb_funcall(rb_mKernel, rb_intern("require"), 1, rb_str_new2("data_objects"));

#ifdef RUBY_LESS_THAN_186
	ID_NEW_DATE = rb_intern("new0");
#else
	ID_NEW_DATE = rb_intern("new!");
#endif
	ID_LOGGER = rb_intern("logger");
	ID_DEBUG = rb_intern("debug");
	ID_LEVEL = rb_intern("level");

	// Get references to the DataObjects module and its classes
	mDO = CONST_GET(rb_mKernel, "DataObjects");
	cDO_Quoting = CONST_GET(mDO, "Quoting");
	cDO_Connection = CONST_GET(mDO, "Connection");
	cDO_Command = CONST_GET(mDO, "Command");
	cDO_Result = CONST_GET(mDO, "Result");
	cDO_Reader = CONST_GET(mDO, "Reader");

	// Initialize the DataObjects::Sqlite3 module, and define its classes
	mSqlite3 = rb_define_module_under(mDO, "Sqlite3");

	eSqlite3Error = rb_define_class("Sqlite3Error", rb_eStandardError);

	cConnection = SQLITE3_CLASS("Connection", cDO_Connection);
	rb_define_method(cConnection, "initialize", cConnection_initialize, 1);
	rb_define_method(cConnection, "dispose", cConnection_dispose, 0);

	cCommand = SQLITE3_CLASS("Command", cDO_Command);
	rb_include_module(cCommand, cDO_Quoting);
	rb_define_method(cCommand, "set_types", cCommand_set_types, 1);
	rb_define_method(cCommand, "execute_non_query", cCommand_execute_non_query, -1);
	rb_define_method(cCommand, "execute_reader", cCommand_execute_reader, -1);
	rb_define_method(cCommand, "quote_boolean", cCommand_quote_boolean, 1);
	rb_define_method(cCommand, "quote_string", cCommand_quote_string, 1);

	cResult = SQLITE3_CLASS("Result", cDO_Result);

	cReader = SQLITE3_CLASS("Reader", cDO_Reader);
	rb_define_method(cReader, "close", cReader_close, 0);
	rb_define_method(cReader, "next!", cReader_next, 0);
	rb_define_method(cReader, "values", cReader_values, 0);
	rb_define_method(cReader, "fields", cReader_fields, 0);

}
