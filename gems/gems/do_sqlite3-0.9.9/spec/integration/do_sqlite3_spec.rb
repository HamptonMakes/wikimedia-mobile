require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe "DataObjects::Sqlite3" do
  include Sqlite3SpecHelpers

  it "should raise error on bad connection string" do
    # lambda { DataObjects::Connection.new("sqlite3:///ac0d9iopalmsdcasd/asdc9pomasd/test.db") }.should raise_error("unable to open database file")
  end
end

NOW = DateTime.now

describe "DataObjects::Sqlite3::Result" do
  include Sqlite3SpecHelpers

  before(:all) do
    @connection = DataObjects::Connection.new("sqlite3://#{File.expand_path(File.dirname(__FILE__))}/test.db")
  end

  after :all do
    @connection.close
  end

  it "should raise an error for a bad query" do
    command = @connection.create_command("INSER INTO table_which_doesnt_exist (id) VALUES (1)")
    lambda { command.execute_non_query }.should raise_error('near "INSER": syntax error')

    command = @connection.create_command("INSERT INTO table_which_doesnt_exist (id) VALUES (1)")
    lambda { command.execute_non_query }.should raise_error("no such table: table_which_doesnt_exist")

    command = @connection.create_command("SELECT * FROM table_which_doesnt_exist")
    lambda { command.execute_reader }.should raise_error("no such table: table_which_doesnt_exist")
  end

  it "should return the affected rows and insert_id" do
    command = @connection.create_command("DROP TABLE users")
    command.execute_non_query rescue nil
    command = @connection.create_command("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, type TEXT, age INTEGER, created_at DATETIME, balance DECIMAL default '0.00')")
    result = command.execute_non_query
    command = @connection.create_command("INSERT INTO users (name) VALUES ('test')")
    result = command.execute_non_query
    result.insert_id.should == 1
    result.to_i.should == 1
  end

  it "should do a reader query" do
    command = @connection.create_command("SELECT * FROM users")
    reader = command.execute_reader

    lambda { reader.values }.should raise_error

    while ( reader.next! )
      lambda { reader.values }.should_not raise_error
      reader.values.should be_a_kind_of(Array)
    end

    lambda { reader.values }.should raise_error

    reader.close
  end

  it "should do a paramaterized reader query" do
    command = @connection.create_command("SELECT * FROM users WHERE id = ?")
    reader = command.execute_reader(1)
    reader.next!

    reader.values[0].should == 1

    reader.next!

    lambda { reader.values }.should raise_error

    reader.close
  end

  it "should do a custom typecast reader" do
    command = @connection.create_command("SELECT name, id FROM users")
    command.set_types [String, String]
    reader = command.execute_reader

    while ( reader.next! )
      reader.fields.should == ["name", "id"]
      reader.values.each { |v| v.should be_a_kind_of(String) }
    end

    reader.close

  end

  it "should handle a null value" do
    id = insert("INSERT INTO users (name) VALUES (NULL)")
    select("SELECT name from users WHERE name is null") do |reader|
      reader.values[0].should == nil
    end
  end

  it "should not convert empty strings to null" do
    id = insert("INSERT INTO users (name) VALUES ('')")
    select("SELECT name FROM users WHERE id = ?", [String], id) do |reader|
      reader.values.first.should == ''
    end
  end

  it "should raise an error when you pass too many or too few types for the expected result set" do
    lambda { select("SELECT name, id FROM users", [String, Integer, String]) }.should raise_error(Sqlite3Error)
  end

  it "should do a custom typecast reader with Class" do
    class Person; end

    id = insert("INSERT INTO users (name, age, type) VALUES (?, ?, ?)", 'Sam', 30, Person)

    select("SELECT name, age, type FROM users WHERE id = ?", [String, Integer, Class], id) do |reader|
      reader.fields.should == ["name", "age", "type"]
      reader.values.should == ["Sam", 30, Person]
    end

    exec("DELETE FROM users WHERE id = ?", id)
  end

  [
    NOW.strftime('%Y-%m-%dT%H:%M:%S'),
    NOW.strftime('%Y-%m-%d %H:%M:%S')
  ].each do |raw_value|
    it "should return #{NOW.to_s} using the LOCAL timezone when typecasting '#{raw_value}'" do

      # Insert a timezone-less DateTime into the DB
      id = insert("INSERT INTO users (name, age, type, created_at) VALUES (?, ?, ?, ?)", 'Sam', 30, Person, raw_value)

      select("SELECT created_at FROM users WHERE id = ?", [DateTime], id) do |reader|
        reader.values.last.to_s.should == NOW.to_s
      end

      exec("DELETE FROM users WHERE id = ?", id)
    end
  end

  it "should not blow up when an empty string for a timestamp is used" do
    id = insert("INSERT INTO users (name, age, type, created_at) VALUES (?, ?, ?, ?)", 'Sam', 30, Person, "")

    select("SELECT created_at FROM users WHERE id = ?", [DateTime], id) do |reader|
      reader.values.last.should == nil
    end
  end

  it "should return DateTimes using the same timezone that was used to insert it" do
    pending "improved support for timezone checking"

    dates = [
      NOW,
      NOW.new_offset( (-11 * 3600).to_r / 86400), # GMT -11:00
      NOW.new_offset( (-9 * 3600 + 10 * 60).to_r / 86400), # GMT -9:10
      NOW.new_offset( (-8 * 3600).to_r / 86400), # GMT -08:00
      NOW.new_offset( (+3 * 3600).to_r / 86400), # GMT +03:00
      NOW.new_offset( (+5 * 3600 + 30 * 60).to_r / 86400)  # GMT +05:30 (New Delhi)
    ]

    dates.each do |date|
      id = insert("INSERT INTO users (name, age, type, created_at) VALUES (?, ?, ?, ?)", 'Sam', 30, Person, date)

      select("SELECT created_at FROM users WHERE id = ?", [DateTime], id) do |reader|
        reader.values.last.year.should == date.year
        reader.values.last.month.should == date.month
        reader.values.last.day.should == date.day
        reader.values.last.hour.should == date.hour
        reader.values.last.min.should == date.min
        reader.values.last.sec.should == date.sec
        reader.values.last.zone.should == date.zone
      end

      exec("DELETE FROM users WHERE id = ?", id)
    end
  end

  it "should return a BigDecimal" do
    balance = BigDecimal.new('10000000000.00')

    id = insert("INSERT INTO users (name, age, type, created_at, balance) VALUES (?, ?, ?, ?, ?)", 'Scott', 27, Person, DateTime.now, balance)

    select("SELECT balance FROM users WHERE id = ?", [BigDecimal], id) do |reader|
      reader.values.last.should == balance
    end
  end

  describe "quoting" do

    before do
      @connection.create_command("DROP TABLE IF EXISTS sail_boats").execute_non_query
      @connection.create_command("CREATE TABLE sail_boats ( id INTEGER PRIMARY KEY, name VARCHAR(50), port VARCHAR(50), notes VARCHAR(50), vintage BOOLEAN )").execute_non_query
      command = @connection.create_command("INSERT INTO sail_boats (id, name, port, name, vintage) VALUES (?, ?, ?, ?, ?)")
      command.execute_non_query(1, "A", "C", "Fortune Pig!", false)
      command.execute_non_query(2, "B", "B", "Happy Cow!", true)
      command.execute_non_query(3, "C", "A", "Spoon", true)
    end

    after do
      @connection.create_command("DROP TABLE sail_boats").execute_non_query
    end

    it "should quote a String" do
      command = @connection.create_command("INSERT INTO users (name) VALUES (?)")
      result = command.execute_non_query("John Doe")
      result.to_i.should == 1
    end

    it "should quote multiple values" do
      command = @connection.create_command("INSERT INTO users (name, age) VALUES (?, ?)")
      result = command.execute_non_query("Sam Smoot", 1)
      result.to_i.should == 1
    end


    it "should handle boolean columns gracefully" do
      command = @connection.create_command("INSERT INTO sail_boats (id, name, port, name, vintage) VALUES (?, ?, ?, ?, ?)")
      result = command.execute_non_query(4, "Scooner", "Port au Prince", "This is one gangster boat!", true)
      result.to_i.should == 1
    end

    it "should quote an Array" do
      command = @connection.create_command("SELECT id, notes FROM sail_boats WHERE (id IN ?)")
      reader = command.execute_reader([1, 2, 3])

      i = 1
      while(reader.next!)
        reader.values[0].should == i
        i += 1
      end
    end

    it "should quote an Array with NULL values returned" do
      command = @connection.create_command("SELECT id, NULL AS notes FROM sail_boats WHERE (id IN ?)")
      reader = command.execute_reader([1, 2, 3])

      i = 1
      while(reader.next!)
        reader.values[0].should == i
        i += 1
      end
    end

    it "should quote an Array with NULL values returned AND set_types called" do
      command = @connection.create_command("SELECT id, NULL AS notes FROM sail_boats WHERE (id IN ?)")
      command.set_types [ Integer, String ]

      reader = command.execute_reader([1, 2, 3])

      i = 1
      while(reader.next!)
        reader.values[0].should == i
        i += 1
      end
    end

  end # describe "quoting"
end
