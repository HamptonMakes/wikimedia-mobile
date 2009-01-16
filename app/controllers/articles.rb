class Articles < Application
  
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
    @name ||= (params[:search] || params[:title] || "").gsub("_", " ")
  end
  
end
