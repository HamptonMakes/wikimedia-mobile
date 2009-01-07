class Articles < Application
  before :setup_ivars
  
  def home
    @main_page = Wikipedia.main_page(request.language_code)
    render
  end
  
  def random
    @article = Article.random(current_server)
    redirect @article.path
  end
  
  def search
    article = Article.new(current_server, params[:search]).fetch!
    redirect article.path
  end
  
  def show
    @name = params[:search] || params[:title]
    # Perform a normal search
    @article = Article.new(current_server, @name)
    @article.fetch!
    display @article, :search
  end
  
  def file
    results = current_server.file(params[:file]).html(:image)
    Merb.logger.debug results
    render results
  end
  
  private 
  def setup_ivars
    @name = ""
  end
  
end
