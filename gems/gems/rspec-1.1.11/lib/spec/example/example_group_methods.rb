module Spec
  module Example

    module ExampleGroupMethods
      include Spec::Example::BeforeAndAfterHooks

      class << self
        attr_accessor :matcher_class

        def description_text(*args)
          args.inject("") do |result, arg|
            result << " " unless (result == "" || arg.to_s =~ /^(\s|\.|#)/)
            result << arg.to_s
          end
        end
      end

      attr_reader :description_text, :description_options, :spec_path
      alias :options :description_options
      
      def description_args
        @description_args ||= []
      end

      def inherited(klass)
        super
        klass.register {}
        Spec::Runner.register_at_exit_hook
      end
      
      # Makes the describe/it syntax available from a class. For example:
      #
      #   class StackSpec < Spec::ExampleGroup
      #     describe Stack, "with no elements"
      #
      #     before
      #       @stack = Stack.new
      #     end
      #
      #     it "should raise on pop" do
      #       lambda{ @stack.pop }.should raise_error
      #     end
      #   end
      #
      def describe(*args, &example_group_block)
        args << {} unless Hash === args.last
        if example_group_block
          options = args.last
          options[:spec_path] = eval("caller(0)[1]", example_group_block) unless options[:spec_path]
          if options[:shared]
            create_shared_example_group(args, example_group_block)
          else
            create_nested_example_group(args, example_group_block)
          end
        else
          set_description(*args)
        end
      end
      alias :context :describe
      
      def create_shared_example_group(args, example_group_block)
        SharedExampleGroup.new(*args, &example_group_block)
      end
      
      def create_nested_example_group(args, example_group_block)
        self.subclass("Subclass") do
          describe(*args)
          module_eval(&example_group_block)
        end
      end
      
      # Use this to pull in examples from shared example groups.
      # See Spec::Runner for information about shared example groups.
      def it_should_behave_like(*shared_example_groups)
        shared_example_groups.each do |group|
          include_shared_example_group(group)
        end
      end
      
      # :call-seq:
      #   predicate_matchers[matcher_name] = method_on_object
      #   predicate_matchers[matcher_name] = [method1_on_object, method2_on_object]
      #
      # Dynamically generates a custom matcher that will match
      # a predicate on your class. RSpec provides a couple of these
      # out of the box:
      #
      #   exist (or state expectations)
      #     File.should exist("path/to/file")
      #
      #   an_instance_of (for mock argument constraints)
      #     mock.should_receive(:message).with(an_instance_of(String))
      #
      # == Examples
      #
      #   class Fish
      #     def can_swim?
      #       true
      #     end
      #   end
      #
      #   describe Fish do
      #     predicate_matchers[:swim] = :can_swim?
      #     it "should swim" do
      #       Fish.new.should swim
      #     end
      #   end
      def predicate_matchers
        @predicate_matchers ||= {:an_instance_of => :is_a?}
      end

      # Creates an instance of the current example group class and adds it to
      # a collection of examples of the current example group.
      def example(description=nil, options={}, &implementation)
        e = new(description, options, &implementation)
        example_objects << e
        e
      end

      alias_method :it, :example
      alias_method :specify, :example

      # Use this to temporarily disable an example.
      def xexample(description=nil, opts={}, &block)
        Kernel.warn("Example disabled: #{description}")
      end
      
      alias_method :xit, :xexample
      alias_method :xspecify, :xexample

      def run
        examples = examples_to_run
        reporter.add_example_group(self) unless examples_to_run.empty?
        return true if examples.empty?
        return dry_run(examples) if dry_run?

        plugin_mock_framework
        define_methods_from_predicate_matchers

        success, before_all_instance_variables = run_before_all
        success, after_all_instance_variables  = execute_examples(success, before_all_instance_variables, examples)
        success                                = run_after_all(success, after_all_instance_variables)
      end

      def description
        result = ExampleGroupMethods.description_text(*description_parts)
        if result.nil? || result == ""
          return to_s
        else
          result
        end
      end

      def described_type
        description_parts.find {|part| part.is_a?(Module)}
      end

      def description_parts #:nodoc:
        parts = []
        each_ancestor_example_group_class do |example_group_class|
          parts << example_group_class.description_args
        end
        parts.flatten.compact
      end

      def set_description(*args)
        args, options = args_and_options(*args)
        @description_args = args
        @description_options = options
        @description_text = ExampleGroupMethods.description_text(*args)
        @spec_path = File.expand_path(options[:spec_path]) if options[:spec_path]
        self
      end
      
      def examples #:nodoc:
        examples = example_objects.dup
        add_method_examples(examples)
        Spec::Runner.options.reverse ? examples.reverse : examples
      end

      def number_of_examples #:nodoc:
        examples.length
      end

      # Only used from RSpec's own examples
      def reset # :nodoc:
        @before_all_parts = nil
        @after_all_parts = nil
        @before_each_parts = nil
        @after_each_parts = nil
      end

      def register(&registration_binding_block)
        @registration_binding_block = registration_binding_block
        Spec::Runner.options.add_example_group self
      end

      def unregister #:nodoc:
        Spec::Runner.options.remove_example_group self
      end

      def registration_backtrace
        eval("caller", @registration_binding_block)
      end

      def run_before_each(example)
        each_ancestor_example_group_class do |example_group_class|
          example.eval_each_fail_fast(example_group_class.before_each_parts)
        end
      end

      def run_after_each(example)
        each_ancestor_example_group_class(:superclass_first) do |example_group_class|
          example.eval_each_fail_slow(example_group_class.after_each_parts)
        end
      end

    private
      def dry_run(examples)
        examples.each do |example|
          Spec::Runner.options.reporter.example_started(example)
          Spec::Runner.options.reporter.example_finished(example)
        end
        return true
      end

      def run_before_all
        before_all = new("before(:all)")
        begin
          each_ancestor_example_group_class do |example_group_class|
            before_all.eval_each_fail_fast(example_group_class.before_all_parts)
          end
          return [true, before_all.instance_variable_hash]
        rescue Exception => e
          reporter.failure(before_all, e)
          return [false, before_all.instance_variable_hash]
        end
      end

      def execute_examples(success, instance_variables, examples)
        return [success, instance_variables] unless success

        after_all_instance_variables = instance_variables
        examples.each do |example_group_instance|
          success &= example_group_instance.execute(Spec::Runner.options, instance_variables)
          after_all_instance_variables = example_group_instance.instance_variable_hash
        end
        return [success, after_all_instance_variables]
      end

      def run_after_all(success, instance_variables)
        after_all = new("after(:all)")
        after_all.set_instance_variables_from_hash(instance_variables)
        each_ancestor_example_group_class(:superclass_first) do |example_group_class|
          after_all.eval_each_fail_slow(example_group_class.after_all_parts)
        end
        return success
      rescue Exception => e
        reporter.failure(after_all, e)
        return false
      end

      def examples_to_run
        all_examples = examples
        return all_examples unless specified_examples?
        all_examples.reject do |example|
          matcher = ExampleGroupMethods.matcher_class.
            new(description.to_s, example.description)
          !matcher.matches?(specified_examples)
        end
      end

      def specified_examples?
        specified_examples && !specified_examples.empty?
      end

      def specified_examples
        Spec::Runner.options.examples
      end

      def reporter
        Spec::Runner.options.reporter
      end

      def dry_run?
        Spec::Runner.options.dry_run
      end

      def example_objects
        @example_objects ||= []
      end

      def each_ancestor_example_group_class(superclass_last=false)
        classes = []
        current_class = self
        while is_example_group_class?(current_class)
          superclass_last ? classes << current_class : classes.unshift(current_class)
          current_class = current_class.superclass
        end
        
        classes.each do |example_group|
          yield example_group
        end
      end

      def is_example_group_class?(klass)
        klass.kind_of?(ExampleGroupMethods) && klass.included_modules.include?(ExampleMethods)
      end

      def plugin_mock_framework
        case mock_framework = Spec::Runner.configuration.mock_framework
        when Module
          include mock_framework
        else
          require Spec::Runner.configuration.mock_framework
          include Spec::Plugins::MockFramework
        end
      end

      def define_methods_from_predicate_matchers # :nodoc:
        all_predicate_matchers = predicate_matchers.merge(
          Spec::Runner.configuration.predicate_matchers
        )
        all_predicate_matchers.each_pair do |matcher_method, method_on_object|
          define_method matcher_method do |*args|
            eval("be_#{method_on_object.to_s.gsub('?','')}(*args)")
          end
        end
      end

      def add_method_examples(examples)
        instance_methods.sort.each do |method_name|
          if example_method?(method_name)
            examples << new(method_name) do
              __send__(method_name)
            end
          end
        end
      end

      def example_method?(method_name)
        should_method?(method_name)
      end

      def should_method?(method_name)
        !(method_name =~ /^should(_not)?$/) &&
        method_name =~ /^should/ && (
          [-1,0].include?(instance_method(method_name).arity)
        )
      end

      def include_shared_example_group(shared_example_group)
        case shared_example_group
        when SharedExampleGroup
          include shared_example_group
        else
          example_group = SharedExampleGroup.find_shared_example_group(shared_example_group)
          unless example_group
            raise RuntimeError.new("Shared Example Group '#{shared_example_group}' can not be found")
          end
          include(example_group)
        end
      end

    end

  end
end
