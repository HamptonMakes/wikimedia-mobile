class Articles < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def search
    if params[:search] == "::Home"
      render :template => "articles/home"
    else
      @article = Article.find("en.wikipedia.org", params[:search])
      render @article.content
    end
  end
  
end
