require 'set'

begin
  require 'fastthread'
rescue LoadError
end

module DataObjects
  class Connection

    def self.new(uri)
      uri = DataObjects::URI::parse(uri)

      if uri.scheme == 'jdbc'
        driver_name = uri.path.split(':').first
      else
        driver_name = uri.scheme.capitalize
      end

      DataObjects.const_get(driver_name.capitalize)::Connection.new(uri)
    end

    def self.inherited(target)
      target.class_eval do

        def self.new(*args)
          instance = allocate
          instance.send(:initialize, *args)
          instance
        end

        include Extlib::Pooling
        alias close release
      end

      if driver_module_name = target.name.split('::')[-2]
        driver_module = DataObjects::const_get(driver_module_name)
        driver_module.class_eval <<-EOS, __FILE__, __LINE__
          def self.logger
            @logger
          end

          def self.logger=(logger)
            @logger = logger
          end
        EOS

        driver_module.logger = DataObjects::Logger.new(nil, :off)
      end
    end

    #####################################################
    # Standard API Definition
    #####################################################
    def to_s
      @uri.to_s
    end

    def initialize(uri)
      raise NotImplementedError.new
    end

    def dispose
      raise NotImplementedError.new
    end

    def create_command(text)
      concrete_command.new(self, text)
    end

    private
    def concrete_command
      @concrete_command || begin

        class << self
          private
          def concrete_command
            @concrete_command
          end
        end

        @concrete_command = DataObjects::const_get(self.class.name.split('::')[-2]).const_get('Command')
      end
    end

  end
end
