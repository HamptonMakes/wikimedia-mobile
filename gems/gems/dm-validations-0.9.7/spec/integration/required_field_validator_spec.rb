require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe DataMapper::Validate::RequiredFieldValidator do

    describe "Resources" do
      before do
        class Landscaper
          include DataMapper::Resource
          property :id, Integer, :key => true
          property :name, String
        end

        class Garden
          include DataMapper::Resource
          property :id, Integer, :key => true
          property :landscaper_id, Integer
          property :name, String, :auto_validation => false

          belongs_to :landscaper #has :landscaper, 1..n

          validates_present :name, :when => :property_test
          validates_present :landscaper, :when => :association_test
        end

        class Fertilizer
          include DataMapper::Resource
          property :id, Integer, :serial => true
          property :brand, String, :auto_validation => false, :default => 'Scotts'
          validates_present :brand, :when => :property_test
        end

        Landscaper.auto_migrate!
        Garden.auto_migrate!
        Fertilizer.auto_migrate!
      end

      it "should validate the presence of a property value on an instance of a resource" do
        garden = Garden.new
        garden.should_not be_valid_for_property_test
        garden.errors.on(:name).should include('Name must not be blank')

        garden.name = 'The Wilds'
        garden.should be_valid_for_property_test
      end

      it "should validate the presence of an association value on an instance of a resource when dirty"
      #do
      #  garden = Garden.new
      #  landscaper = garden.landscaper
      #  puts landscaper.children.length
      #  #puts "Gardens landscaper is #{garden.landscaper.child_key}"
      #end

      it "should pass when a default is available" do
        fert = Fertilizer.new
        fert.should be_valid_for_property_test
      end
    end

    describe "A plain class (not a DM resource)" do

      before do
        class PlainClass
          extend DataMapper::Validate::ClassMethods
          include DataMapper::Validate
          attr_accessor :accessor
          validates_present :here, :empty, :nil, :accessor
          def here;  "here" end
          def empty; ""     end
          def nil;   nil    end
        end

        @pc = PlainClass.new
      end

      it "should fail validation with empty, nil, or blank fields" do
        @pc.should_not be_valid
        @pc.errors.on(:empty).should    include("Empty must not be blank")
        @pc.errors.on(:nil).should      include("Nil must not be blank")
        @pc.errors.on(:accessor).should include("Accessor must not be blank")
      end

      it "giving accessor a value should remove validation error" do
        @pc.accessor = "full"
        @pc.valid?
        @pc.errors.on(:accessor).should be_nil
      end
    end

  end
end
