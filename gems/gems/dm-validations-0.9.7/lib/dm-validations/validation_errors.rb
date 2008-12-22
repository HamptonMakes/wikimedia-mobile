module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class ValidationErrors

      include Enumerable

      # Clear existing validation errors.
      def clear!
        errors.clear
      end

      # Add a validation error. Use the field_name :general if the errors does
      # not apply to a specific field of the Resource.
      #
      # @param <Symbol> field_name the name of the field that caused the error
      # @param <String> message    the message to add
      def add(field_name, message)
        (errors[field_name] ||= []) << message
      end

      # Collect all errors into a single list.
      def full_messages
        errors.inject([]) do |list,pair|
          list += pair.last
        end
      end

      # Return validation errors for a particular field_name.
      #
      # @param <Symbol> field_name the name of the field you want an error for
      def on(field_name)
        errors_for_field = errors[field_name]
        errors_for_field.blank? ? nil : errors_for_field
      end

      def each
        errors.map.each do |k,v|
          next if v.blank?
          yield(v)
        end
      end

      def empty?
        entries.empty?
      end

      def method_missing(meth, *args, &block)
        errors.send(meth, *args, &block)
      end

      private
      def errors
        @errors ||= {}
      end

    end # class ValidationErrors
  end # module Validate
end # module DataMapper
