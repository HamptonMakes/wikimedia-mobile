class Articles < Application
  provides :wml
  provides :html
  provides :json
  override! :content_type

  def home
    Cache.cache(cache_key, Time.now+60*60*24) do # Cache for 24 hours
      @main_page = Wikipedia.main_page(request.language_code)
      format_display_with_data do
        {:title => "::Home", :html => render(:layout => false)}
      end
    end
  end
  
  def random
    @article = Article.random(current_server)
    redirect(@article.path)
  end
  
  def show
    if current_name == ""
      redirect "/wiki/::Home"
    elsif current_name[0..1] == "::"
      redirect "/wiki/#{current_name}"
    else
      # Perform a normal search
      @article = Article.new(current_server, current_name)
      @article.fetch!
      format_display_with_data do
        @article.to_hash(request.device)
      end
    end
  end
  
  def file
    @article = current_server.file(params[:file])
    format_display_with_data do
      @article.to_hash(request.device)
    end
  end
  
 private 
 
  def format_display_with_data(&block)
    case content_type
    when :json
      json = JSON.dump(block.call)
      if params[:callback]
        json = "#{params[:callback]}(#{json})"
      end
      render json, :format => :json
    else
      render :layout => request.device.with_layout
    end
  end
 
  def content_type
    if params[:format]
      params[:format].to_sym
    else
      :html
    end
  end
  
  def current_name
    @name ||= (params[:search] || params[:title] || "").gsub("_", " ")
  end
  
  def cache_key
    "#{self.class.name}##{self.action_name}##{request.language_code}##{request.device.format_name}##{content_type}##{params[:callback]}}"
  end
end
