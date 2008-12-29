class Articles < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def search
    
    # TODO: These if statements should really be done at the router
    if params[:search] == "::Home"
      # Run the article page.
      @main_page = Wikipedia.main_page(language_code)
      render :template => "articles/home", :format => content_type
      
    elsif params[:search] == "::Random"
      # load a random article
      @article = current_server.random_article
      render @article.content
    else
      # Perform a normal search
      @article = current_server.find_article(params[:search])
      render @article.content
    end
    
    
  end
  
end
