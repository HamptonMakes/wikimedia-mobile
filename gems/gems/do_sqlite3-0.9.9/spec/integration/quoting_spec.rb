require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataObjects::Sqlite3::Command do

  before(:each) do
    @connection = DataObjects::Connection.new("sqlite3://#{File.expand_path(File.dirname(__FILE__))}/test.db")
    @command = @connection.create_command("INSERT INTO users (name) VALUES (?)")
  end

  it "should properly quote a string" do
    @command.quote_string("O'Hare").should == "'O''Hare'"
    @command.quote_string("Willy O'Hare & Johnny O'Toole").should == "'Willy O''Hare & Johnny O''Toole'"
    @command.quote_string("Billy\\Bob").should == "'Billy\\Bob'"
    @command.quote_string("The\\Backslasher\\Rises\\Again").should == "'The\\Backslasher\\Rises\\Again'"
    @command.quote_string("Scott \"The Rage\" Bauer").should == "'Scott \"The Rage\" Bauer'"
  end

end
