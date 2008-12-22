require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataObjects::Sqlite3::Command do

  before(:each) do
    @connection = DataObjects::Connection.new("sqlite3://#{File.expand_path(File.dirname(__FILE__))}/test.db")
  end

  after(:each) do
    @connection.close
  end

  describe "Executing a Reader" do

    it "should log reader queries when the level is Debug (0)" do
      command = @connection.create_command("SELECT * FROM users")
      @mock_logger = mock('MockLogger', :level => 0)
      DataObjects::Sqlite3.should_receive(:logger).and_return(@mock_logger)
      @mock_logger.should_receive(:debug).with("SELECT * FROM users")
      command.execute_reader
    end

    it "shouldn't log reader queries when the level isn't Debug (0)" do
      command = @connection.create_command("SELECT * FROM users")
      @mock_logger = mock('MockLogger', :level => 1)
      DataObjects::Sqlite3.should_receive(:logger).and_return(@mock_logger)
      @mock_logger.should_not_receive(:debug)
      command.execute_reader
    end
  end

  describe "Executing a Non-Query" do
    it "should log non-query statements when the level is Debug (0)" do
      command = @connection.create_command("INSERT INTO users (name) VALUES (?)")
      @mock_logger = mock('MockLogger', :level => 0)
      DataObjects::Sqlite3.should_receive(:logger).and_return(@mock_logger)
      @mock_logger.should_receive(:debug).with("INSERT INTO users (name) VALUES ('Blah')")
      command.execute_non_query('Blah')
    end

    it "shouldn't log non-query statements when the level isn't Debug (0)" do
      command = @connection.create_command("INSERT INTO users (name) VALUES (?)")
      @mock_logger = mock('MockLogger', :level => 1)
      DataObjects::Sqlite3.should_receive(:logger).and_return(@mock_logger)
      @mock_logger.should_not_receive(:debug)
      command.execute_non_query('Blah')
    end
  end

end
