$TESTING=true

require 'rubygems'
require 'spec'
require 'date'
require 'pathname'

# put data_objects from repository in the load path
# DO NOT USE installed gem of data_objects!
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'data_objects', 'lib'))
require 'data_objects'

# put the pre-compiled extension in the path to be found
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'do_sqlite3'

log_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'log', 'do.log'))
FileUtils.mkdir_p(File.dirname(log_path))

DataObjects::Sqlite3.logger = DataObjects::Logger.new(log_path, 0)

at_exit { DataObjects.logger.flush }

module Sqlite3SpecHelpers

  def insert(query, *args)
    result = @connection.create_command(query).execute_non_query(*args)
    result.insert_id
  end

  def exec(query, *args)
    @connection.create_command(query).execute_non_query(*args)
  end

  def select(query, types = nil, *args)
    begin
      command = @connection.create_command(query)
      command.set_types types unless types.nil?
      reader = command.execute_reader(*args)
      reader.next!
      yield reader
    ensure
      reader.close if reader
    end
  end

end
