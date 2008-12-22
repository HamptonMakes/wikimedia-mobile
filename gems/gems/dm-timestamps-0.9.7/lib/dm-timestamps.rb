require 'rubygems'

gem 'dm-core', '~>0.9.7'
require 'dm-core'

module DataMapper
  module Timestamp
    TIMESTAMP_PROPERTIES = {
      :updated_at => lambda { |r| r.updated_at = DateTime.now },
      :updated_on => lambda { |r| r.updated_on = Date.today   },
      :created_at => lambda { |r| r.created_at = DateTime.now if r.new_record? && r.created_at.nil? },
      :created_on => lambda { |r| r.created_on = Date.today   if r.new_record? && r.created_on.nil?},
    }

    def self.included(model)
      model.before :save, :set_timestamp_properties
      model.send :extend, ClassMethods
    end

    private

    def set_timestamp_properties
      if dirty?
        self.class.properties.slice(*TIMESTAMP_PROPERTIES.keys).compact.each do |property|
          TIMESTAMP_PROPERTIES[property.name][self] unless attribute_dirty?(property.name)
        end
      end
    end

    module ClassMethods
      def timestamps(*args)
        if args.empty? then raise ArgumentError, "You need to pass at least one argument." end

        args.each do |ts|
          case ts
          when :at
            property :created_at, DateTime
            property :updated_at, DateTime
          when :on
            property :created_on, Date
            property :updated_on, Date
          else
            unless TIMESTAMP_PROPERTIES.keys.include?(ts)
              raise InvalidTimestampName, "Invalid timestamp property '#{ts}'."
            end

            property ts, DateTime
          end
        end
      end
    end

    class InvalidTimestampName < RuntimeError; end
  end # module Timestamp

  Resource::append_inclusions Timestamp
end
