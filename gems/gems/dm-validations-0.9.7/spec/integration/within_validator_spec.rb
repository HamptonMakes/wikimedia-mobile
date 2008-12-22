require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Validate::WithinValidator do
  before(:all) do
    class Telephone
      include DataMapper::Resource
      property :id, Integer, :serial => true
      property :type_of_number, String, :auto_validation => false
      validates_within :type_of_number, :set => ['Home','Work','Cell']
    end

    class Inf
      include DataMapper::Resource
      property :id, Integer, :serial => true
      property :greater_than, String, :auto_validation => false
      property :less_than, String, :auto_validation => false
      property :between, String, :auto_validation => false
      validates_within :greater_than, :set => (10..n)
      validates_within :less_than, :set => (-n..10)
      validates_within :between, :set => (10..20)
    end

    class Receiver
      include DataMapper::Resource
      property :id, Integer, :serial => true
      property :holder, String, :auto_validation => false, :default => 'foo'
      validates_within :holder, :set => ['foo', 'bar', 'bang']
    end
  end

  it "should validate a value on an instance of a resource within a predefined
      set of values" do
    tel = Telephone.new
    tel.valid?.should_not == true
    tel.errors.full_messages.first.should == 'Type of number must be one of [Home, Work, Cell]'

    tel.type_of_number = 'Cell'
    tel.valid?.should == true
  end

  it "should validate a value within range with infinity" do
    inf = Inf.new
    inf.should_not be_valid
    inf.errors.on(:greater_than).first.should == 'Greater than must be greater than 10'
    inf.errors.on(:less_than).first.should == 'Less than must be less than 10'
    inf.errors.on(:between).first.should == 'Between must be between 10 and 20'
  end

  it "should validate a value by its default" do
    tel = Receiver.new
    tel.should be_valid
  end
end
