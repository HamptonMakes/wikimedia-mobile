class Articles < Application
  
  def home
    cache(Time.now+60*60*24) do # Cache for 24 hours
      @main_page = Wikipedia.main_page(request.language_code)
      render
    end
  end
  
  def random
    @article = Article.random(current_server)
    redirect @article.path
  end
  
  def show
    # Perform a normal search
    @article = Article.new(current_server, current_name)
    @article.fetch!
    display @article, :search
  end
  
  def file
    @article = current_server.file(params[:file])
    render
  end
  
 private 
  def current_name
    @name ||= (params[:search] || params[:title] || "").gsub("_", " ")
  end
  
  def cache(expires)
    data= Cache.read(cache_key)
    unless data
      data= yield # run action
      Cache.write(cache_key, data, :expires=>expires)
      # TODO: Find a better cache expiring strategy that considers when the original page on wikipedia gets updated
    end
    data
  end
  
  def cache_key
    "#{self.class.name}##{self.action_name}##{request.language_code}"
  end
end
