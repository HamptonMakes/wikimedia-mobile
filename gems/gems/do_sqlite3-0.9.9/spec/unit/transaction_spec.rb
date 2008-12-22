require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataObjects::Sqlite3::Transaction do

  before :each do
    @connection = mock("connection")
    DataObjects::Connection.should_receive(:new).with("mock://mock/mock").once.and_return(@connection)
    @transaction = DataObjects::Sqlite3::Transaction.new("mock://mock/mock")
    @transaction.id.replace("id")
    @command = mock("command")
  end

  {
    :begin => "BEGIN",
    :commit => "COMMIT",
    :rollback => "ROLLBACK",
    :rollback_prepared => "ROLLBACK",
    :prepare => nil
  }.each do |method, commands|
    it "should execute #{commands.inspect} on ##{method}" do
      if commands.is_a?(String)
        @command.should_receive(:execute_non_query).once
        @connection.should_receive(:create_command).once.with(commands).and_return(@command)
        @transaction.send(method)
      elsif commands.nil?
        @command.should_not_receive(:execute_non_query)
        @connection.should_not_receive(:create_command)
        @transaction.send(method)
      end
    end
  end

end
