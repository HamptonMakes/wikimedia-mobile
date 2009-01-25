class Articles < Application
  provides :wml
  
  provides :html, :wml
  
  def home
    Cache.cache(cache_key, Time.now+60*60*24) do # Cache for 24 hours
      @main_page = Wikipedia.main_page(request.language_code)
      render
    end
  end
  
  def random
    @article = Article.random(current_server)
    redirect @article.path
  end
  
  def show
    if current_name == ""
      redirect "/wiki/::Home"
    else
      # Perform a normal search
      @article = Article.new(current_server, current_name)
      @article.fetch!
      display @article, :search
    end
  end
  
  def file
    @article = current_server.file(params[:file])
    render
  end
  
 private 
  def current_name
    @name ||= (params[:search] || params[:title] || "").gsub("_", " ")
  end
  
  def cache_key
    "#{self.class.name}##{self.action_name}##{request.language_code}"
  end
end
