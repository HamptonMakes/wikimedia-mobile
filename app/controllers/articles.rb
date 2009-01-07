class Articles < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def search
    @name = ""
    
    # TODO: These if statements should really be done at the router
    if params[:search] == "::Home"
      # Run the article page.
      @main_page = Wikipedia.main_page(language_code)
      render :template => "articles/home", :format => content_type
    elsif params[:search] == "::Random"
      # load a random article
      @article = Article.random_article(current_server)
      redirect @article.path
    else
      @name = params[:search] || params[:title]
      # Perform a normal search
      @article = Article.new(current_server, @name)
      @article.fetch!
      display @article
    end
    
    
  end
  
  def file
    results = current_server.file(params[:file]).html(:image)
    Merb.logger.debug results
    render results
  end
  
end
