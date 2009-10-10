task :versions do
  Dir["/Users/hcatlin/.rvm/*"].each do |path|
    if path.include?("ruby-")
      ruby_executable = path + "/bin/ruby"
      version = `#{ruby_executable} --version`.split(" ")[1]
      
      puts "Starting #{version}"
      puts `#{ruby_executable} /usr/bin/merb -a thin -e production -p 4000 -d`
      sleep(5.0)
      puts "loaded " + `curl -s -S http://localhost:4000/wiki/Haml | wc`
      
      puts "Stopping #{version}"
      puts `#{ruby_executable} /usr/bin/merb -K 4000`
    end
  end
end