class Version
  def initialize(ruby)
    @ruby = ruby
    @path = ruby.split("/")[0..-2].join("/")
    @gem = @path + "/gem"
    @hit_counter = 0
    
    @port = rand(2000) + 2000
    
    Log.d @gem
    if File.exists?(ruby)
      @name = `#{ruby} --version`.split(" ")[1]
      Log.d  "Successfully loaded #{@name}"
    else
      throw "Can't find #{ruby}"
    end
  end
  
  def is_running?
    (`curl -s http://localhost:#{@port}/ | wc`).split(" ").first.to_i > 10
  end
  
  def install
    # NOT USING BUNDLER FOR THE MOMENT
    #Log.d "Installing gems"
    #run "#{@gem} install bundler --no-ri --no-rdoc"
    #run "#{@gem} bundle"
    #run "#{@path}"
  end
  
  def boot
    Log.d "Booting #{@name}"
    #Log.d  `memcached -d`
    
    time_to "startup server" do
      run "#{@path}/ruby /Users/hcatlin/.rvm/gems/ruby/1.8.6/bin/merb -a thin -e development -p #{@port} -d"
      
      tries = 0
      
      while(!is_running? && tries <= 50)
        sleep(0.1)
        tries += 1
      end

      if !is_running?
        Log.error("Server failed to launch")
        return false
      end
    end
    
    Log.d "Successfully started merb server"
    
    Log.r "Taking up #{memory_usage[:real_memory]}"
    return true
  end
  
  def shutdown
    Log.d "Shutting down Merb"
    #Log.d  `pkill memcached`
    run "merb -K #{@port}"
    #Log.d "Cleaning up Gem cache"
  end
  
  def memory_usage
    result = run("ps -o rss -o vsize -o comm | grep ruby").split("\n")[0].split(" ")[0..1]
    {:virtual_memory => result[1], :real_memory => result[0]}
  end
  
  def to_mb(number)
    (number / 1000).to_i
  end
end