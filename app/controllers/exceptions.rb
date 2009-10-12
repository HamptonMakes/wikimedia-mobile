class Exceptions < Application
  
  
  if %w( staging production ).include?(Merb.env)
    after :notify_of_exceptions, :only => :standard_error

    def standard_error
      #HoptoadNotifier.notify_hoptoad(request, session)
      render_and_notify :format => :html
    end
  end
  
  # handle NotFound exceptions (404)
  def not_found
    #HoptoadNotifier.notify_hoptoad(request, session) if Merb.env == "production"
    #puts request.exceptions.first.inspect
    render :format => :html
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

end