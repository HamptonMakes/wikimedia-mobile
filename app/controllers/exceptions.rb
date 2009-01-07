class Exceptions < Application
  if %w( staging production ).include?(Merb.env)
    def standard_error
      HoptoadNotifier.notify_hoptoad(request, session)
      render "Something went wrong...", :format => :html, :layout => false
    end
  end
  
  # handle NotFound exceptions (404)
  def not_found
    HoptoadNotifier.notify_hoptoad(request, session) if Merb.env == "production"
    puts request.exceptions.first.inspect
    render :format => :html
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

end