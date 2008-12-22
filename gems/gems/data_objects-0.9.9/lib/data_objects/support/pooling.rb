require 'set'

class Object
  # ==== Notes
  # Provides pooling support to class it got included in.
  #
  # Pooling of objects is a faster way of aquiring instances
  # of objects compared to regular allocation and initialization
  # because instances are keeped in memory reused.
  #
  # Classes that include Pooling module have re-defined new
  # method that returns instances acquired from pool.
  #
  # Term resource is used for any type of poolable objects
  # and should NOT be thought as DataMapper Resource or
  # ActiveResource resource and such.
  #
  # In Data Objects connections are pooled so that it is
  # unnecessary to allocate and initialize connection object
  # each time connection is needed, like per request in a
  # web application.
  #
  # Pool obviously has to be thread safe because state of
  # object is reset when it is released.
  module Pooling
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      # ==== Notes
      # Initializes the pool and returns it.
      #
      # ==== Parameters
      # size_limit<Fixnum>:: maximum size of the pool.
      #
      # ==== Returns
      # <ResourcePool>:: initialized pool
      def initialize_pool(size_limit, options = {})
        @__pool.flush! if @__pool

        @__pool = ResourcePool.new(size_limit, self, options)
      end

      # ==== Notes
      # Instances of poolable resource are acquired from
      # pool. This quires a new instance from pool and
      # returns it.
      #
      # ==== Returns
      # Resource instance acquired from the pool.
      #
      # ==== Raises
      # ArgumentError:: when pool is exhausted and no instance
      #                 can be acquired.
      def new
        pool.acquire
      end

      # ==== Notes
      # Returns pool for this resource class.
      # Initialization is done when necessary.
      # Default size limit of the pool is 10.
      #
      # ==== Returns
      # <Object::Pooling::ResourcePool>:: pool for this resource class.
      def pool
        @__pool ||= ResourcePool.new(10, self)
      end
    end

    # ==== Notes
    # Pool
    #
    class ResourcePool
      attr_reader :size_limit, :class_of_resources, :expiration_period

      # ==== Notes
      # Initializes resource pool.
      #
      # ==== Parameters
      # size_limit<Fixnum>:: maximum number of resources in the pool.
      # class_of_resources<Class>:: class of resource.
      #
      # ==== Raises
      # ArgumentError:: when class of resource does not implement
      #                 dispose instance method or is not a Class.
      def initialize(size_limit, class_of_resources, options)
        raise ArgumentError.new("Expected class of resources to be instance of Class, got: #{class_of_resources.class}") unless class_of_resources.is_a?(Class)
        raise ArgumentError.new("Class #{class_of_resources} must implement dispose instance method to be poolable.") unless class_of_resources.instance_methods.include?("dispose")

        @size_limit         = size_limit
        @class_of_resources = class_of_resources

        @reserved  = Set.new
        @available = []
        @lock      = Mutex.new

        initialization_args  = options.delete(:initialization_args) || []

        @expiration_period   = options.delete(:expiration_period) || 60
        @initialization_args = [*initialization_args]

        @pool_expiration_thread = Thread.new do
          while true
            release_outdated

            sleep (@expiration_period + 1)
          end
        end
      end

      # ==== Notes
      # Current size of pool: number of already reserved
      # resources.
      def size
        @reserved.size
      end

      # ==== Notes
      # Indicates if pool has resources to acquire.
      #
      # ==== Returns
      # <Boolean>:: true if pool has resources can be acquired,
      #             false otherwise.
      def available?
        @reserved.size < size_limit
      end

      # ==== Notes
      # Acquires last used available resource and returns it.
      # If no resources available, current implementation
      # throws an exception.
      def acquire
        @lock.synchronize do
          if available?
            instance = prepair_available_resource
            @reserved << instance

            instance
          else
            raise RuntimeError
          end
        end
      end

      # ==== Notes
      # Releases previously acquired instance.
      #
      # ==== Parameters
      # instance <Anything>:: previosly acquired instance.
      #
      # ==== Raises
      # RuntimeError:: when given not pooled instance.
      def release(instance)
        @lock.synchronize do
          if @reserved.include?(instance)
            @reserved.delete(instance)
            instance.dispose
            @available << instance
          else
            raise RuntimeError
          end
        end
      end

      # ==== Notes
      # Releases all objects in the pool.
      #
      # ==== Returns
      # nil
      def flush!
        @reserved.each do |instance|
          self.release(instance)
        end

        nil
      end

      # ==== Notes
      # Check if instance has been acquired from the pool.
      #
      # ==== Returns
      # <Boolean>:: true if given resource instance has been acquired from pool,
      #             false otherwise.
      def acquired?(instance)
        @reserved.include?(instance)
      end

      # ==== Notes
      # Releases instances that haven't been in use and
      # hit the expiration period.
      #
      # ==== Returns
      # nil
      def release_outdated
        @reserved.each do |instance|
          release(instance) if time_to_release?(instance)
        end

        nil
      end

      # ==== Notes
      # Checks if pooled resource instance is outdated and
      # should be released.
      #
      # ==== Returns
      # <Boolean>:: true if instance should be released, false otherwise.
      def time_to_release?(instance)
        (Time.now - instance.instance_variable_get("@__pool_acquire_timestamp")) > @expiration_period
      end

      protected

      # ==== Notes
      # Either allocates new resource,
      # or takes last used available resource from
      # the pool.
      def prepair_available_resource
        if @available.size > 0
          res = @available.pop
          res.instance_variable_set("@__pool_acquire_timestamp", Time.now)

          res
        else
          res = @class_of_resources.allocate
          res.send(:initialize, *@initialization_args)
          res.instance_variable_set("@__pool_acquire_timestamp", Time.now)

          res
        end
      end
    end # ResourcePool
  end
end
