class Articles < Application
  before :read_cache, :only=>:home
  after  :write_cache, :only=>:home
  
  def home
    @main_page = Wikipedia.main_page(request.language_code)
    render
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
    @name ||= (params[:search] || params[:title] || nil).gsub("_", " ")
  end
  
  def read_cache
    if data= Cache.read(cache_key)
      @cached= true
      throw(:halt, data)
    end
  end
  
  def write_cache
    unless @cached
      Cache.write(cache_key, self.body, :expires=>Time.now+60*60*24) # Cache for 24 hours
      # TODO: Find a better cache expiring strategy that considers when the original page on wikipedia gets updated
    end
  end
  
  def cache_key
    "#{self.class.name}##{self.action_name}##{request.language_code}"
  end
end
