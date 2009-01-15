class Articles < Application
  before :setup_ivars
  
  def home
    @name = "::Home"
    unless Merb::Cache[:memcached].exists?("home_page", {:language_code =>  request.language_code}) 
      @main_page = Wikipedia.main_page(request.language_code)
      Merb::Cache[:memcached].write("home_page",
                                    Wikipedia.main_page(request.language_code) ,
                                     {:language_code =>  request.language_code} , 
                                      :expires_in => 86400) # i can put 1.day
    else                                             
      @main_page = Merb::Cache[:memcached].read("home_page",{:language_code =>  request.language_code})
    end 
    render
  end
  
  def random
    @article = Article.random(current_server)
    redirect @article.path
  end
  
  def show
    @name = params[:search] || params[:title]
    # Perform a normal search
    @article = Article.new(current_server, @name)
    @article.fetch!
    display @article, :search
  end
  
  def file
    @article = current_server.file(params[:file])
    render
  end
  
 private 
  def setup_ivars
    @name = ""
  end
  
end
