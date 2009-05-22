class Articles < Application
  provides :wml
  provides :html
  provides :json
  override! :content_type

  def home
    Cache.cache(cache_key, Time.now+60*60*24) do # Cache for 24 hours
      @main_page = Wikipedia.main_page(request.language_code)
      case content_type
      when :json
        display({:title => "::Home", :content => @main_page})
      else
        render :layout => request.device.with_layout
      end
    end
  end
  
  def random
    @article = Article.random(current_server)
    redirect(@article.path)
  end
  
  def show
    if current_name == ""
      redirect "/wiki/::Home"
    elsif current_name[0..1] == "::"
      redirect "/wiki/#{current_name}"
    else
      # Perform a normal search
      @article = Article.new(current_server, current_name)
      @article.fetch!
      case content_type
      when :json
        display @article.to_hash(request.device)
      else
        render :layout => request.device.with_layout
      end
    end
  end
  
  def file
    @article = current_server.file(params[:file])
    case content_type
    when :json
      display @article.to_hash(request.device)
    else
      render :layout => request.device.with_layout
    end
  end
  
 private 
 
  def content_type
    if params[:format]
      params[:format].to_sym
    else
      :html
    end
  end
  
  def current_name
    @name ||= (params[:search] || params[:title] || "").gsub("_", " ")
  end
  
  def cache_key
    "#{self.class.name}##{self.action_name}##{request.language_code}##{request.device.format_name}##{content_type}"
  end
end
