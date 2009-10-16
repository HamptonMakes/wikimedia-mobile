class Articles < Application
  provides :wml
  provides :html
  provides :json
  override! :content_type

  def home
    cache_block do
      if settings = Wikipedia.settings[request.language_code]
        if settings['mobile_main_page']
          redirect "/wiki/" + settings['mobile_main_page']
        else
          @main_page = Wikipedia.main_page(request.language_code)
        end
      end
    
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
      @article = Article.new(current_server, current_name, nil, request.device)
      
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
    Merb.logger.debug("CTYPE: #{content_type}")
    case content_type
    when :json
      json = JSON.dump(block.call)
      if params[:callback]
        json = "#{params[:callback]}(#{json})"
      end
      render json, :format => :json
    else
      case content_type
      when :wml
        @headers["Content-Type"] = "text/vnd.wap.wml; charset=utf-8"
      end
      render :layout => request.device.with_layout
    end
  end
 
  def content_type
    (params[:format] || request.device.view_format).to_sym
  end
  
  def cache_block(&block)
    begin
      time_to "cache block" do
      
        key = cache_key
        html = Cache[key]
        Merb.logger.debug("KEY: #{key}")
      
        if html
          Merb.logger.debug("CACHE HIT")
          return html
        else
          html = block.call
        
          time_to "store in cache" do
            Cache.store(key, html, :expires_in => 60 * 60 * 12)
          end

          Merb.logger.debug("CACHE MISS")
        end
        html
      end
    # If memcached is unavailable for some reason, then don't barf... just fetch
    rescue MemCache::MemCacheError
      return block.call
    end
  end
  
  def current_name
    @name ||= (params[:search] || params[:title] || params[:file] || "").gsub("_", " ")
  end
  
  def cache_key
    "#{request.language_code}/#{request.device.format_name}/#{content_type}##{params[:callback]}".gsub(" ", "-")
  end
end
