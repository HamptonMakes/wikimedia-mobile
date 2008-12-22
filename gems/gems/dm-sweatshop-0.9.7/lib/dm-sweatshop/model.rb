module DataMapper
  # Methods added to this module are available on classes
  # that include DataMapper::Resource.
  #
  # This lets you use Person.pick(:michael) instead of
  # DataMapper::Sweatshop.pick(Person, :michael)
  module Model
    # Adds a fixture to record map.
    # Block is supposed to return a hash of attributes.
    #
    # @param  name  [Symbol, String]  Name of the fixture
    # @param  blk   [Proc]            A proc that returns fixture attributes
    #
    # @returns nil
    #
    # @api    public
    def fixture(name = default_fauxture_name, &blk)
      Sweatshop.add(self, name, &blk)
    end

    alias_method :fix, :fixture

    # Creates an instance from hash of attributes, saves it
    # and adds it to the record map. Attributes given as the
    # second argument are merged into attributes from fixture.
    #
    # If record is valid because of duplicated property value,
    # this method does a retry.
    #
    # @param     name        [Symbol]
    # @param     attributes  [Hash]
    #
    # @api       public
    #
    # @returns   [DataMapper::Resource]    added instance
    def generate(name = default_fauxture_name, attributes = {})
      name, attributes = default_fauxture_name, name if name.is_a? Hash
      Sweatshop.create(self, name, attributes)
    end

    alias_method :gen, :generate

    # Returns a Hash of attributes from the model map.
    #
    # @param     name     [Symbol]   name of the fauxture to use
    #
    # @returns   [Hash]              existing instance of a model from the model map
    # @raises    NoFixtureExist      when requested fixture does not exist in the model map
    #
    # @api       public
    def generate_attributes(name = default_fauxture_name)
      Sweatshop.attributes(self, name)
    end

    alias_method :gen_attrs, :generate_attributes

    # Creates an instance from given hash of attributes
    # and adds it to records map without saving.
    #
    # @param     name        [Symbol]      name of the fauxture to use
    # @param     attributes  [Hash]
    #
    # @api       private
    #
    # @returns   [DataMapper::Resource]    added instance
    def make(name = default_fauxture_name, attributes = {})
      name, attributes = default_fauxture_name, name if name.is_a? Hash
      Sweatshop.make(self, name, attributes)
    end

    # Returns a pre existing instance of a model from the record map
    #
    # @param     name     [Symbol]                        name of the fauxture to pick
    #
    # @returns   [DataMapper::Resource]                   existing instance of a model from the record map
    # @raises     DataMapper::Sweatshop::NoFixtureExist   when requested fixture does not exist in the record map
    #
    # @api       public
    def pick(name = default_fauxture_name)
      Sweatshop.pick(self, name)
    end

    # Default fauxture name. Usually :default.
    #
    # @returns   [Symbol]   default fauxture name
    # @api       public
    def default_fauxture_name
      :default
    end
  end
end
