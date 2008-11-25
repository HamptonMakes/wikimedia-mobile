class Articles < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def search
    @article = Article.find("en.wikipedia.org", params[:title])
    render @article.content
  end
  
end
