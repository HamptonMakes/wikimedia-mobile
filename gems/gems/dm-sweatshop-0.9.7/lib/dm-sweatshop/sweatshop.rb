module DataMapper
  class Sweatshop
    # Raise when requested attributes hash or instance are not
    # found in model and record maps, respectively.
    #
    # This usually happens when you forget to use +make+ or
    # +generate+ method before trying ti +pick+ an object.
    class NoFixtureExist < Exception
    end

    class << self
      attr_accessor :model_map
      attr_accessor :record_map
    end

    # Models map stores named Procs for a class.
    # Each Proc must return a Hash of attributes.
    self.model_map = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] = []}}
    # Records map stores named instances of a class.
    # Those instances may or may not be new records.
    self.record_map = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] = []}}

    # Adds a Proc to model map. Proc must return a Hash of attributes.
    #
    # @param     klass      [Class, DataMapper::Resource]
    # @param     name       [Symbol]
    # @param     instance   [DataMapper::Resource]
    #
    # @api       private
    #
    # @returns   [Array]    model map
    def self.add(klass, name, &proc)
      self.model_map[klass][name.to_sym] << proc
    end

    # Adds an instance to records map.
    #
    # @param     klass      [Class, DataMapper::Resource]
    # @param     name       [Symbol]
    # @param     instance   [DataMapper::Resource]
    #
    # @api       private
    #
    # @returns   [DataMapper::Resource]    added instance
    def self.record(klass, name, instance)
      self.record_map[klass][name.to_sym] << instance
      instance
    end

    # Creates an instance from given hash of attributes, saves it
    # and adds it to the record map.
    #
    # @param     klass       [Class, DataMapper::Resource]
    # @param     name        [Symbol]
    # @param     attributes  [Hash]
    #
    # @api       private
    #
    # @returns   [DataMapper::Resource]    added instance
    def self.create(klass, name, attributes = {})
      record(klass, name, klass.create(attributes(klass, name).merge(attributes)))
    end

    # Creates an instance from given hash of attributes
    # and adds it to records map without saving.
    #
    # @param     klass       [Class, DataMapper::Resource]
    # @param     name        [Symbol]
    # @param     attributes  [Hash]
    #
    # @api       private
    #
    # @returns   [DataMapper::Resource]    added instance
    def self.make(klass, name, attributes = {})
      record(klass, name, klass.new(attributes(klass, name).merge(attributes)))
    end

    # Returns a pre existing instance of a model from the record map
    #
    # @param     klass    [Class, DataMapper::Resource]
    # @param     name     [Symbol]
    #
    # @returns   [DataMapper::Resource]                   existing instance of a model from the record map
    # @raises     DataMapper::Sweatshop::NoFixtureExist   when requested fixture does not exist in the record map
    #
    # @api       private
    def self.pick(klass, name)
      self.record_map[klass][name.to_sym].pick || raise(NoFixtureExist, "no #{name} context fixtures have been generated for the #{klass} class")
    end

    # Returns a Hash of attributes from the model map
    #
    # @param     klass    [Class, DataMapper::Resource]
    # @param     name     [Symbol]
    #
    # @returns   [Hash]          existing instance of a model from the model map
    # @raises    NoFixtureExist  when requested fixture does not exist in the model map
    #
    # @api       private
    def self.attributes(klass, name)
      proc = model_map[klass][name.to_sym].pick

      if proc
        proc.call
      elsif klass.superclass.is_a?(DataMapper::Model)
        attributes(klass.superclass, name)
      else
        raise NoFixtureExist, "#{name} fixture was not found for class #{klass}"
      end
    end
  end
end
