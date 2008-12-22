require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

[:sqlite3, :mysql, :postgres].each do |adapter|
  next unless eval("HAS_#{adapter.to_s.upcase}")
  describe "Using Adapter #{adapter}," do
    describe DataMapper::Migration, "#create_table helper" do
      before do
        @creator = DataMapper::Migration::TableCreator.new(repository(adapter).adapter, :people) do
          column :id, Integer, :serial => true
          column :name, 'varchar(50)'
          column :long_string, String, :size => 200
        end
      end

      it "should have a #create_table helper" do
        @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) { }
        @migration.should respond_to(:create_table)
      end

      it "should have a table_name" do
        @creator.table_name.should == "people"
      end

      it "should have an adapter" do
        @creator.instance_eval("@adapter").should == repository(adapter).adapter
      end

      it "should have an options hash" do
        @creator.opts.should be_kind_of(Hash)
        @creator.opts.should == {}
      end

      it "should have an array of columns" do
        @creator.instance_eval("@columns").should be_kind_of(Array)
        @creator.instance_eval("@columns").should have(3).items
        @creator.instance_eval("@columns").first.should be_kind_of(DataMapper::Migration::TableCreator::Column)
      end

      it "should quote the table name for the adapter" do
        @creator.quoted_table_name.should == (adapter == :mysql ? '`people`' : '"people"')
      end

      it "should allow for custom options" do
        columns = @creator.instance_eval("@columns")
        col = columns.detect{|c| c.name == "long_string"}
        col.instance_eval("@type").should include("200")
      end

    end

    describe DataMapper::Migration, "#modify_table helper" do
      before do
        @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) { }
      end

      it "should have a #modify_table helper" do
        @migration.should respond_to(:modify_table)
      end

    end

    describe DataMapper::Migration, "other helpers" do
      before do
        @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) { }
      end

      it "should have a #drop_table helper" do
        @migration.should respond_to(:drop_table)
      end

    end

    describe DataMapper::Migration, "version tracking" do
      before do
        @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) do
          up   { :ran_up }
          down { :ran_down }
        end

        @migration.send(:create_migration_info_table_if_needed)
      end

      def insert_migration_record
        DataMapper.repository.adapter.execute("INSERT INTO migration_info (migration_name) VALUES ('create_people_table')")
      end

      it "should know if the migration_info table exists" do
        @migration.send(:migration_info_table_exists?).should be_true
      end

      it "should know if the migration_info table does not exist" do
        repository.adapter.execute("DROP TABLE migration_info") rescue nil
        @migration.send(:migration_info_table_exists?).should be_false
      end

      it "should be able to find the migration_info record for itself" do
        insert_migration_record
        @migration.send(:migration_record).should_not be_empty
      end

      it "should know if a migration needs_up?" do
        @migration.send(:needs_up?).should be_true
        insert_migration_record
        @migration.send(:needs_up?).should be_false
      end

      it "should know if a migration needs_down?" do
        @migration.send(:needs_down?).should be_false
        insert_migration_record
        @migration.send(:needs_down?).should be_true
      end

      it "should properly quote the migration_info table for use in queries" do
        @migration.send(:migration_info_table).should == '"migration_info"'
      end

      it "should properly quote the migration_info.migration_name column for use in queries" do
        @migration.send(:migration_name_column).should == '"migration_name"'
      end

      it "should properly quote the migration's name for use in queries"
      # TODO how to i call the adapter's #escape_sql method?

      it "should create the migration_info table if it doesn't exist" do
        repository.adapter.execute("DROP TABLE migration_info")
        @migration.send(:migration_info_table_exists?).should be_false
        @migration.send(:create_migration_info_table_if_needed)
        @migration.send(:migration_info_table_exists?).should be_true
      end

      it "should insert a record into the migration_info table on up" do
        @migration.send(:migration_record).should be_empty
        @migration.perform_up.should == :ran_up
        @migration.send(:migration_record).should_not be_empty
      end

      it "should remove a record from the migration_info table on down" do
        insert_migration_record
        @migration.send(:migration_record).should_not be_empty
        @migration.perform_down.should == :ran_down
        @migration.send(:migration_record).should be_empty
      end

      it "should not run the up action if the record exists in the table" do
        insert_migration_record
        @migration.perform_up.should_not == :ran_up
      end

      it "should not run the down action if the record does not exist in the table" do
        @migration.perform_down.should_not == :ran_down
      end

      after do
        repository.adapter.execute("DELETE FROM migration_info") if @migration.send(:migration_info_table_exists?)
      end
    end
  end
end
