require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Timestamp' do
    before :all do
      class GreenSmoothie
        include DataMapper::Resource

        property :id, Integer, :serial => true
        property :name, String
        property :created_at, DateTime
        property :created_on, Date
        property :updated_at, DateTime
        property :updated_on, Date

        auto_migrate!(:default)
      end
    end

    after do
     repository(:default).adapter.execute('DELETE from green_smoothies');
    end

    it "should not set the created_at/on fields if they're already set" do
      repository(:default) do
        green_smoothie = GreenSmoothie.new(:name => 'Banana')
        time = (DateTime.now - 100)
        green_smoothie.created_at = time
        green_smoothie.created_on = time
        green_smoothie.save
        green_smoothie.created_at.should == time
        green_smoothie.created_on.should == time
        green_smoothie.created_at.should be_a_kind_of(DateTime)
        green_smoothie.created_on.should be_a_kind_of(Date)
      end
    end

    it "should set the created_at/on fields on creation" do
      repository(:default) do
        green_smoothie = GreenSmoothie.new(:name => 'Banana')
        green_smoothie.created_at.should be_nil
        green_smoothie.created_on.should be_nil
        green_smoothie.save
        green_smoothie.created_at.should be_a_kind_of(DateTime)
        green_smoothie.created_on.should be_a_kind_of(Date)
      end
    end

    it "should not alter the create_at/on fields on model updates" do
      repository(:default) do
        green_smoothie = GreenSmoothie.new(:id => 2, :name => 'Berry')
        green_smoothie.created_at.should be_nil
        green_smoothie.created_on.should be_nil
        green_smoothie.save
        original_created_at = green_smoothie.created_at
        original_created_on = green_smoothie.created_on
        green_smoothie.name = 'Strawberry'
        green_smoothie.save
        green_smoothie.created_at.should eql(original_created_at)
        green_smoothie.created_on.should eql(original_created_on)
      end
    end

    it "should set the updated_at/on fields on creation and on update" do
      repository(:default) do
        green_smoothie = GreenSmoothie.new(:name => 'Mango')
        green_smoothie.updated_at.should be_nil
        green_smoothie.updated_on.should be_nil
        green_smoothie.save
        green_smoothie.updated_at.should be_a_kind_of(DateTime)
        green_smoothie.updated_on.should be_a_kind_of(Date)
        original_updated_at = green_smoothie.updated_at
        original_updated_on = green_smoothie.updated_on
        time_tomorrow = DateTime.now + 1
        date_tomorrow = Date.today + 1
        DateTime.stub!(:now).and_return { time_tomorrow }
        Date.stub!(:today).and_return { date_tomorrow }
        green_smoothie.name = 'Cranberry Mango'
        green_smoothie.save
        green_smoothie.updated_at.should_not eql(original_updated_at)
        green_smoothie.updated_on.should_not eql(original_updated_on)
        green_smoothie.updated_at.should eql(time_tomorrow)
        green_smoothie.updated_on.should eql(date_tomorrow)
      end
    end

    it "should only set the updated_at/on fields on dirty objects" do
      repository(:default) do
        green_smoothie = GreenSmoothie.new(:name => 'Mango')
        green_smoothie.updated_at.should be_nil
        green_smoothie.updated_on.should be_nil
        green_smoothie.save
        green_smoothie.updated_at.should be_a_kind_of(DateTime)
        green_smoothie.updated_on.should be_a_kind_of(Date)
        original_updated_at = green_smoothie.updated_at
        original_updated_on = green_smoothie.updated_on
        time_tomorrow = DateTime.now + 1
        date_tomorrow = Date.today + 1
        DateTime.stub!(:now).and_return { time_tomorrow }
        Date.stub!(:today).and_return { date_tomorrow }
        green_smoothie.save
        green_smoothie.updated_at.should_not eql(time_tomorrow)
        green_smoothie.updated_on.should_not eql(date_tomorrow)
        green_smoothie.updated_at.should eql(original_updated_at)
        green_smoothie.updated_on.should eql(original_updated_on)
      end
    end

    describe "inclusion" do
      before :each do
        @klass = Class.new do
          include DataMapper::Resource
        end
      end

      it "should provide #timestamps" do
        @klass.should respond_to(:timestamps)
      end

      it "should set the *at properties" do
        @klass.timestamps :at

        @klass.properties.should have_property(:created_at)
        @klass.properties[:created_at].type.should == DateTime
        @klass.properties.should have_property(:updated_at)
        @klass.properties[:updated_at].type.should == DateTime
      end

      it "should set the *on properties" do
        @klass.timestamps :on

        @klass.properties.should have_property(:created_on)
        @klass.properties[:created_on].type.should == Date
        @klass.properties.should have_property(:updated_on)
        @klass.properties[:updated_on].type.should == Date
      end

      it "should set multiple properties" do
        @klass.timestamps :created_at, :updated_on

        @klass.properties.should have_property(:created_at)
        @klass.properties.should have_property(:updated_on)
      end

      it "should fail on unknown property name" do
        lambda { @klass.timestamps :wowee }.should raise_error(DataMapper::Timestamp::InvalidTimestampName)
      end

      it "should fail on empty arguments" do
        lambda { @klass.timestamps }.should raise_error(ArgumentError)
      end
    end
  end
end
