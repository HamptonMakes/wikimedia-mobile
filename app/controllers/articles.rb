class Articles < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def search
    
    if params[:search] == "::Home"
      # Run the article page.
      # TODO: This home page needs to be modernized... its going out to a lib file, and that's not cool.
      render :template => "articles/home"
      
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
