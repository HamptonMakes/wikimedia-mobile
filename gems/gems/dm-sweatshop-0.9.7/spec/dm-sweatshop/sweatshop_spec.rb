require File.dirname(__FILE__) + '/../spec_helper'

describe DataMapper::Sweatshop do

  class Parent
    include DataMapper::Resource
    property :id, Integer, :serial => true
    property :type, Discriminator
    property :first_name, String
    property :last_name, String
  end

  class Child < Parent
    property :age, Integer
  end

  before(:each) do
    DataMapper.auto_migrate!
    DataMapper::Sweatshop.model_map.clear
    DataMapper::Sweatshop.record_map.clear
  end

  describe ".model_map" do
    it "should return a Hash if the model is not mapped" do
      DataMapper::Sweatshop.model_map[Class.new].should be_is_a(Hash)
    end

    it "should return a map for names to an array of procs if the model is not mapped" do
      DataMapper::Sweatshop.model_map[Class.new][:unnamed].should be_is_a(Array)
    end
  end

  describe ".add" do
    it "should app a generator proc to the model map" do
      proc = lambda {}
      lambda {
        DataMapper::Sweatshop.add(Parent, :default, &proc)
      }.should change {
        DataMapper::Sweatshop.model_map[Parent][:default].first
      }.from(nil).to(proc)
    end

    it "should push repeat procs onto the mapped array" do
      proc1, proc2 = lambda {}, lambda {}

      DataMapper::Sweatshop.add(Parent, :default, &proc1)
      DataMapper::Sweatshop.add(Parent, :default, &proc2)

      DataMapper::Sweatshop.model_map[Parent][:default].first.should == proc1
      DataMapper::Sweatshop.model_map[Parent][:default].last.should == proc2
    end
  end

  describe ".attributes" do
    it "should return an attributes hash" do
      DataMapper::Sweatshop.add(Parent, :default) {{
        :first_name => /\w+/.gen.capitalize,
        :last_name => /\w+/.gen.capitalize
      }}

      DataMapper::Sweatshop.attributes(Parent, :default).should be_is_a(Hash)
    end

    it "should call the attribute proc on each call to attributes" do
      calls = 0
      proc = lambda {{:calls => (calls += 1)}}

      DataMapper::Sweatshop.add(Parent, :default, &proc)
      DataMapper::Sweatshop.attributes(Parent, :default).should == {:calls => 1}
      DataMapper::Sweatshop.attributes(Parent, :default).should == {:calls => 2}
    end

    it "should call attributes with the superclass if the class is not mapped" do
      DataMapper::Sweatshop.add(Parent, :default) {{:first_name => 'Bob'}}
      DataMapper::Sweatshop.attributes(Child, :default).should == {:first_name => 'Bob'}
    end

    it "should raise an error if neither the class or it's parent class(es) have been mapped" do
      lambda { DataMapper::Sweatshop.attributes(Child, :default) }.
        should raise_error(DataMapper::Sweatshop::NoFixtureExist, /default fixture was not found for class/)
    end
  end

  describe ".create" do
    it "should call create on the model class with the attributes generated from a mapped proc" do
      DataMapper::Sweatshop.add(Parent, :default) {{
        :first_name => 'Kenny',
        :last_name => 'Rogers'
      }}

      Parent.should_receive(:create).with(:first_name => 'Kenny', :last_name => 'Rogers')

      DataMapper::Sweatshop.create(Parent, :default)
    end

    it "should call create on the model with a parent class' mapped attributes proc when the original class has not been maped" do
      DataMapper::Sweatshop.add(Parent, :default) {{
        :first_name => 'Kenny',
        :last_name => 'Rogers'
      }}

      Child.should_receive(:create).with(:first_name => 'Kenny', :last_name => 'Rogers')

      DataMapper::Sweatshop.create(Child, :default)
    end

    it "should merge in any attributes as an argument" do
      DataMapper::Sweatshop.add(Parent, :default) {{
        :first_name => 'Kenny',
        :last_name => 'Rogers'
      }}

      Parent.should_receive(:create).with(:first_name => 'Roddy', :last_name => 'Rogers')

      DataMapper::Sweatshop.create(Parent, :default, :first_name => 'Roddy')
    end
  end

  describe ".make" do
    it "should call new on the model class with the attributes generated from a mapped proc" do
      DataMapper::Sweatshop.add(Parent, :default) {{
        :first_name => 'Kenny',
        :last_name => 'Rogers'
      }}

      Parent.should_receive(:new).with(:first_name => 'Kenny', :last_name => 'Rogers')

      DataMapper::Sweatshop.make(Parent, :default)
    end
  end

  describe ".pick" do
    it "should return a pre existing instance of a model from the record map" do
      DataMapper::Sweatshop.add(Parent, :default) {{
        :first_name => 'George',
        :last_name => 'Clinton'
      }}

      DataMapper::Sweatshop.create(Parent, :default)

      DataMapper::Sweatshop.pick(Parent, :default).should be_is_a(Parent)
    end
  end
end
