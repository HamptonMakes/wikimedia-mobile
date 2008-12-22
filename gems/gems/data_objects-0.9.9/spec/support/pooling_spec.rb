require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'data_objects', 'support', 'pooling')
require 'timeout'

# This implements dispose
# and works perfectly with
# pooling.
class DisposableResource
  include Object::Pooling
  attr_reader :name

  def initialize(name = "")
    @name = name
  end

  def dispose
    @name = nil
  end
end

# This baby causes exceptions
# to be raised when you use
# it with pooling.
class UndisposableResource
end

describe Object::Pooling::ResourcePool do
  before :each do
    @pool = Object::Pooling::ResourcePool.new(7, DisposableResource, :expiration_period => 50)
  end

  it "responds to flush!" do
    @pool.should respond_to(:flush!)
  end

  it "responds to acquire" do
    @pool.should respond_to(:acquire)
  end

  it "responds to release" do
    @pool.should respond_to(:release)
  end

  it "responds to :available?" do
    @pool.should respond_to(:available?)
  end

  it "has a size limit" do
    @pool.size_limit.should == 7
  end

  it "has initial size of zero" do
    @pool.size.should == 0
  end

  it "has a set of reserved resources" do
    @pool.instance_variable_get("@reserved").should be_empty
  end

  it "has a set of available resources" do
    @pool.instance_variable_get("@available").should be_empty
  end

  it "knows class of resources (objects) it works with" do
    @pool.class_of_resources.should == DisposableResource
  end

  it "raises exception when given anything but class for resources class" do
    lambda {
      @pool = Object::Pooling::ResourcePool.new(7, "Hooray!", {})
    }.should raise_error(ArgumentError, /class/)
  end

  it "requires class of resources (objects) it works with to have a dispose instance method" do
    lambda {
      @pool = Object::Pooling::ResourcePool.new(3, UndisposableResource, {})
    }.should raise_error(ArgumentError, /dispose/)
  end

  it "may take initialization arguments" do
    @pool = Object::Pooling::ResourcePool.new(7, DisposableResource, { :initialization_args => ["paper"] })
    @pool.instance_variable_get("@initialization_args").should == ["paper"]
  end

  it "may take expiration period option" do
    @pool = Object::Pooling::ResourcePool.new(7, DisposableResource, { :expiration_period => 100 })
    @pool.expiration_period.should == 100
  end

  it "has default expiration period of one minute" do
    @pool = Object::Pooling::ResourcePool.new(7, DisposableResource, {})
    @pool.expiration_period.should == 60
  end

  it "spawns a thread to dispose objects haven't been used for a while" do
    @pool = Object::Pooling::ResourcePool.new(7, DisposableResource, {})
    @pool.instance_variable_get("@pool_expiration_thread").should be_an_instance_of(Thread)
  end
end



describe "Acquire from constant size pool" do
  before :each do
    DisposableResource.initialize_pool(2)
  end

  after :each do
    DisposableResource.instance_variable_set("@__pool", nil)
  end

  it "increased size of the pool" do
    @time = DisposableResource.pool.acquire
    DisposableResource.pool.size.should == 1
  end

  it "places initialized instance in the reserved set" do
    @time = DisposableResource.pool.acquire
    DisposableResource.pool.instance_variable_get("@reserved").size.should == 1
  end

  it "raises an exception when pool size limit is hit" do
    @t1 = DisposableResource.pool.acquire
    @t2 = DisposableResource.pool.acquire

    lambda { DisposableResource.pool.acquire }.should raise_error(RuntimeError)
  end

  it "returns last released resource" do
    @t1 = DisposableResource.pool.acquire
    @t2 = DisposableResource.pool.acquire
    DisposableResource.pool.release(@t1)

    DisposableResource.pool.acquire.should == @t1
  end

  it "really truly returns last released resource" do
    @t1 = DisposableResource.pool.acquire
    DisposableResource.pool.release(@t1)

    @t2 = DisposableResource.pool.acquire
    DisposableResource.pool.release(@t2)

    @t3 = DisposableResource.pool.acquire
    DisposableResource.pool.release(@t3)

    DisposableResource.pool.acquire.should == @t1
    @t1.should == @t3
  end

  it "sets allocation timestamp on resource instance" do
    @t1 = DisposableResource.new
    @t1.instance_variable_get("@__pool_acquire_timestamp").should be_close(Time.now, 2)
  end
end



describe "Releasing from constant size pool" do
  before :each do
    DisposableResource.initialize_pool(2)
  end

  after :each do
    DisposableResource.instance_variable_set("@__pool", nil)
  end

  it "decreases size of the pool" do
    @t1 = DisposableResource.pool.acquire
    @t2 = DisposableResource.pool.acquire
    DisposableResource.pool.release(@t1)

    DisposableResource.pool.size.should == 1
  end

  it "raises an exception on attempt to releases object not in pool" do
    @t1 = DisposableResource.new
    @t2 = Set.new

    DisposableResource.pool.release(@t1)
    lambda { DisposableResource.pool.release(@t2) }.should raise_error(RuntimeError)
  end

  it "disposes released object" do
    @t1 = DisposableResource.pool.acquire

    @t1.should_receive(:dispose)
    DisposableResource.pool.release(@t1)
  end

  it "removes released object from reserved set" do
    @t1 = DisposableResource.pool.acquire

    lambda {
      DisposableResource.pool.release(@t1)
    }.should change(DisposableResource.pool.instance_variable_get("@reserved"), :size).by(-1)
  end

  it "returns released object back to available set" do
    @t1 = DisposableResource.pool.acquire

    lambda {
      DisposableResource.pool.release(@t1)
    }.should change(DisposableResource.pool.instance_variable_get("@available"), :size).by(1)
  end

  it "updates acquire timestamp on already allocated resource instance" do
    # acquire it once
    @t1 = DisposableResource.new
    # wait a bit
    sleep 3

    # check old timestamp
    @t1.instance_variable_get("@__pool_acquire_timestamp").should be_close(Time.now, 4)

    # re-acquire
    DisposableResource.pool.release(@t1)
    @t1 = DisposableResource.new
    # see timestamp is updated
    @t1.instance_variable_get("@__pool_acquire_timestamp").should be_close(Time.now, 2)
  end
end



describe Object::Pooling::ResourcePool, "#available?" do
  before :each do
    DisposableResource.initialize_pool(2)
    DisposableResource.new
  end

  after :each do
    DisposableResource.instance_variable_set("@__pool", nil)
  end

  it "returns true when pool has available instances" do
    DisposableResource.pool.should be_available
  end

  it "returns false when pool is exhausted" do
    # acquires the last available resource
    DisposableResource.new
    DisposableResource.pool.should_not be_available
  end
end



describe "Flushing of constant size pool" do
  before :each do
    DisposableResource.initialize_pool(2)

    @t1 = DisposableResource.new
    @t2 = DisposableResource.new

    # sanity check
    DisposableResource.pool.instance_variable_get("@reserved").should_not be_empty
  end

  after :each do
    DisposableResource.instance_variable_set("@__pool", nil)
  end

  it "disposes all pooled objects" do
    [@t1, @t2].each { |instance| instance.should_receive(:dispose) }

    DisposableResource.pool.flush!
  end

  it "empties reserved set" do
    DisposableResource.pool.flush!

    DisposableResource.pool.instance_variable_get("@reserved").should be_empty
  end

  it "returns all instances to available set" do
    DisposableResource.pool.flush!

    DisposableResource.pool.instance_variable_get("@available").size.should == 2
  end
end



describe "Poolable resource class" do
  before :each do
    DisposableResource.initialize_pool(3, :initialization_args => ["paper"])
  end

  after :each do
    DisposableResource.instance_variable_set("@__pool", nil)
  end

  it "acquires new instances from pool" do
    @instance_one = DisposableResource.new

    DisposableResource.pool.acquired?(@instance_one).should be(true)
  end

  it "flushed existing pool on re-initialization" do
    DisposableResource.pool.should_receive(:flush!)
    DisposableResource.initialize_pool(5)
  end

  it "replaces pool on re-initialization" do
    DisposableResource.initialize_pool(5)
    DisposableResource.pool.size_limit.should == 5
  end

  it "passes initialization parameters to newly created resource instances" do
    DisposableResource.new.name.should == "paper"
  end
end



describe "Pooled object", "on initialization" do
  after :each do
    DisposableResource.instance_variable_set("@__pool", nil)
  end

  it "does not flush pool" do
    # using pool here initializes the pool first
    # so we use instance variable directly
    DisposableResource.instance_variable_get("@__pool").should_not_receive(:flush!)
    DisposableResource.initialize_pool(23)
  end

  it "flushes pool first when re-initialized" do
    DisposableResource.initialize_pool(5)
    DisposableResource.pool.should_receive(:flush!)
    DisposableResource.initialize_pool(23)
  end
end



describe Object::Pooling::ResourcePool, "#time_to_dispose?" do
  before :each do
    DisposableResource.initialize_pool(7, :expiration_period => 2)
  end

  after :each do
    DisposableResource.instance_variable_set("@__pool", nil)
  end

  it "returns true when object's last acquisition time is greater than limit" do
    @t1 = DisposableResource.new
    DisposableResource.pool.time_to_release?(@t1).should be(false)

    sleep 3
    DisposableResource.pool.time_to_release?(@t1).should be(true)
  end
end



describe Object::Pooling::ResourcePool, "#dispose_outdated" do
  before :each do
    DisposableResource.initialize_pool(7, :expiration_period => 2)
  end

  after :each do
    DisposableResource.instance_variable_set("@__pool", nil)
  end

  it "releases and thus disposes outdated instances" do
    @t1 = DisposableResource.new
    DisposableResource.pool.should_receive(:time_to_release?).with(@t1).and_return(true)
    DisposableResource.pool.should_receive(:release).with(@t1)

    DisposableResource.pool.release_outdated
  end
end
