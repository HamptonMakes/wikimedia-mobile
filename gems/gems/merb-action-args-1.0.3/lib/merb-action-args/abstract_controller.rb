class Merb::AbstractController
  
  class << self
    attr_accessor :action_argument_list
    alias_method :old_inherited, :inherited

    # Stores the argument lists for all methods for this class.
    #
    # ==== Parameters
    # klass<Class>::
    #   The controller that is being inherited from Merb::AbstractController.
    def inherited(klass)
      klass.action_argument_list = Hash.new do |h,k|
        args = klass.instance_method(k).get_args
        arguments = args[0]
        defaults = []
        arguments.each {|a| defaults << a[0] if a.size == 2} if arguments
        h[k] = [arguments || [], defaults]
      end
      old_inherited(klass)
    end
  end

  # Calls an action and maps the params hash to the action parameters.
  #
  # ==== Parameters
  # action<Symbol>:: The action to call
  #
  # ==== Raises
  # BadRequest:: The params hash doesn't have a required parameter.
  def _call_action(action)
    arguments, defaults = self.class.action_argument_list[action]
    
    args = arguments.map do |arg, default|
      arg = arg
      p = params.key?(arg.to_sym)
      raise BadRequest unless p || (defaults && defaults.include?(arg))
      p ? params[arg.to_sym] : default
    end
    __send__(action, *args)
  end
end