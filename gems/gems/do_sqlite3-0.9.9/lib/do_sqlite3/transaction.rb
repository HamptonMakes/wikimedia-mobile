
module DataObjects

  module Sqlite3

    class Transaction < DataObjects::Transaction

      def begin
        cmd = "BEGIN"
        connection.create_command(cmd).execute_non_query
      end

      def commit
        cmd = "COMMIT"
        connection.create_command(cmd).execute_non_query
      end

      def rollback
        cmd = "ROLLBACK"
        connection.create_command(cmd).execute_non_query
      end

      def rollback_prepared
        cmd = "ROLLBACK"
        connection.create_command(cmd).execute_non_query
      end

      def prepare
        # Eek, I don't know how to do this. Lets hope a commit arrives soon...
      end

    end

  end

end
