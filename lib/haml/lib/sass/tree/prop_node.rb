module Sass::Tree
  # A static node reprenting a CSS property.
  #
  # @see Sass::Tree
  class PropNode < Node
    # The name of the property.
    #
    # @return [String]
    attr_accessor :name

    # The value of the property,
    # either a plain string or a SassScript parse tree.
    #
    # @return [String, Script::Node]
    attr_accessor :value

    # @param name [String] See \{#name}
    # @param value [String] See \{#value}
    # @param prop_syntax [Symbol] `:new` if this property uses `a: b`-style syntax,
    #   `:old` if it uses `:a b`-style syntax
    def initialize(name, value, prop_syntax)
      @name = name
      @value = value
      @prop_syntax = prop_syntax
      super()
    end

    # Compares the names and values of two properties.
    #
    # @param other [Object] The object to compare with
    # @return [Boolean] Whether or not this node and the other object
    #   are the same
    def ==(other)
      self.class == other.class && name == other.name && value == other.value && super
    end

    # Computes the CSS for the property.
    #
    # @param tabs [Fixnum] The level of indentation for the CSS
    # @param parent_name [String] The name of the parent property (e.g. `text`) or nil
    # @return [String] The resulting CSS
    # @raise [Sass::SyntaxError] if the property uses invalid syntax
    def to_s(tabs, parent_name = nil)
      if @options[:property_syntax] == :old && @prop_syntax == :new
        raise Sass::SyntaxError.new("Illegal property syntax: can't use new syntax when :property_syntax => :old is set.")
      elsif @options[:property_syntax] == :new && @prop_syntax == :old
        raise Sass::SyntaxError.new("Illegal property syntax: can't use old syntax when :property_syntax => :new is set.")
      end

      if value[-1] == ?;
        raise Sass::SyntaxError.new("Invalid property: #{declaration.dump} (no \";\" required at end-of-line).", @line)
      end
      real_name = name
      real_name = "#{parent_name}-#{real_name}" if parent_name
      
      if value.empty? && children.empty?
        raise Sass::SyntaxError.new("Invalid property: #{declaration.dump} (no value).", @line)
      end
      
      join_string = case style
                    when :compact; ' '
                    when :compressed; ''
                    else "\n"
                    end
      spaces = '  ' * (tabs - 1)
      to_return = ''
      if !value.empty?
        to_return << "#{spaces}#{real_name}:#{style == :compressed ? '' : ' '}#{value};#{join_string}"
      end
      
      children.each do |kid|
        next if kid.invisible?
        to_return << kid.to_s(tabs, real_name) << join_string
      end
      
      (style == :compressed && parent_name) ? to_return : to_return[0...-1]
    end

    protected

    # Runs any SassScript that may be embedded in the property.
    #
    # @param environment [Sass::Environment] The lexical environment containing
    #   variable and mixin values
    def perform!(environment)
      @name = interpolate(@name, environment)
      @value = @value.is_a?(String) ? interpolate(@value, environment) : @value.perform(environment).to_s
      super
    end

    # Returns an error message if the given child node is invalid,
    # and false otherwise.
    #
    # {PropNode} only allows other {PropNode}s and {CommentNode}s as children.
    # @param child [Tree::Node] A potential child node
    # @return [String] An error message if the child is invalid, or nil otherwise
    def invalid_child?(child)
      if !child.is_a?(PropNode) && !child.is_a?(CommentNode)
        "Illegal nesting: Only properties may be nested beneath properties."
      end
    end

    private

    def declaration
      @prop_syntax == :new ? "#{name}: #{value}" : ":#{name} #{value}"
    end
  end
end
