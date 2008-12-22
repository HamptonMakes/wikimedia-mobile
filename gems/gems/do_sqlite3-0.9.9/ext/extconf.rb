# ENV["RC_ARCHS"] = `uname -m`.chomp if `uname -sr` =~ /^Darwin/
#
# require 'mkmf'
#
# SWIG_WRAP = "sqlite3_api_wrap.c"
#
# dir_config( "sqlite3", "/usr/local" )
#
# if have_header( "sqlite3.h" ) && have_library( "sqlite3", "sqlite3_open" )
#   create_makefile( "sqlite3_c" )
# end

if RUBY_PLATFORM =~ /darwin/
  ENV["RC_ARCHS"] = `uname -m`.chomp if `uname -sr` =~ /^Darwin/

  # On PowerPC the defaults are fine
  ENV["RC_ARCHS"] = '' if `uname -m` =~ /^Power Macintosh/
end

# Loads mkmf which is used to make makefiles for Ruby extensions
require 'mkmf'

# Give it a name
extension_name = 'do_sqlite3_ext'

dir_config("sqlite3")

# NOTE: use GCC flags unless Visual C compiler is used
$CFLAGS << ' -Wall ' unless RUBY_PLATFORM =~ /mswin/

if RUBY_VERSION < '1.8.6'
  $CFLAGS << ' -DRUBY_LESS_THAN_186'
elsif RUBY_VERSION >= '1.9.0'
  $CFLAGS << ' -DRUBY_19_COMPATIBILITY'
end

# Do the work
# create_makefile(extension_name)
if have_header( "sqlite3.h" ) && have_library( "sqlite3", "sqlite3_open" )
  create_makefile(extension_name)
end
