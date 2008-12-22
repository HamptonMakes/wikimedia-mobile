module DataMapper
  class Sweatshop
    module Unique
      # Yields a value to the block. The value is unique for each invocation
      # with the same block. Alternatively, you may provide an explicit key to
      # identify the block.
      #
      # If a block with no parameter is supplied, unique keeps track of previous
      # invocations, and will continue yielding until a unique value is generated.
      # If a unique value is not generated after @UniqueWorker::MAX_TRIES@, an exception
      # is raised.
      #
      # ParseTree is required unless an explicit key is provided
      #
      #   (1..3).collect { unique {|x| x }}     # => [0, 1, 2]
      #   (1..3).collect { unique {|x| x + 1 }} # => [1, 2, 3]
      #   (1..3).collect { unique {|x| x }}     # => [3, 4, 5] # Continued on from above
      #   (1..3).collect { unique(:a) {|x| x }} # => [0, 1, 2] # Explicit key overrides block identity
      #
      #   a = [1, 1, 1, 2, 2, 3]
      #   (1..3).collect { unique { a.shift }}  # => [1, 2, 3]
      #   (1..3).collect { unique { 1 }}        # raises TooManyTriesException
      #
      # return <Object> the return value of the block
      def unique(key = nil, &block)
        if block.arity < 1
          UniqueWorker.unique_map ||= {}

          key ||= UniqueWorker.key_for(&block)
          set = UniqueWorker.unique_map[key] || Set.new
          result = block[]
          tries = 0
          while set.include?(result)
            result = block[]
            tries += 1

            raise TooManyTriesException.new("Could not generate unique value after #{tries} attempts") if tries >= UniqueWorker::MAX_TRIES
          end
          set << result
          UniqueWorker.unique_map[key] = set
        else
          UniqueWorker.count_map ||= Hash.new() { 0 }

          key ||= UniqueWorker.key_for(&block)
          result = block[UniqueWorker.count_map[key]]
          UniqueWorker.count_map[key] += 1
        end

        result
      end

      class TooManyTriesException < RuntimeError; end;
    end
    extend(Unique)

    class UniqueWorker
      MAX_TRIES = 10

      begin
        require 'parse_tree'
      rescue LoadError
        puts "DataMapper::Sweatshop::Unique - ParseTree could not be loaded, anonymous uniques will not be allowed"
      end

      cattr_accessor :count_map
      cattr_accessor :unique_map
      cattr_accessor :parser

      # Use the sexp representation of the block as a unique key for the block
      # If you copy and paste a block, it will still have the same key
      #
      # return <Object> the unique key for the block
      def self.key_for(&block)
        raise "You need to install ParseTree to use anonymous an anonymous unique (gem install ParseTree). In the mean time, explicitly declare a key: unique(:my_key) { ... }" unless Object::const_defined?("ParseTree")

        klass = Class.new
        name = "tmp"
        klass.send(:define_method, name, &block)
        self.parser ||= ParseTree.new(false)
        self.parser.parse_tree_for_method(klass, name).last
      end
    end
  end
end
