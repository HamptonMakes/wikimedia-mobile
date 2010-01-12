#!/usr/bin/env ruby

rubies = [#{}"ree-1.8.7-20090928", 
          "ruby-1.8.6-p383", 
          "ruby-1.8.7-p174", 
          "ruby-1.9.1-p129", 
          "ruby-1.9.1-p243", 
          "ruby-1.9.1-rc2", 
          "ruby-1.9.2-preview1"]

require File.join(File.dirname(__FILE__), "version")
require File.join(File.dirname(__FILE__), "log")

Log.log("r", "error")

def run(line)
  Log.e(line)
  result = `#{line}`
  Log.o(result)
  result
end

def time_to(thing, &block)
  start_time = Time.now
  result = block.call
  Log.d("#{thing} took " + (Time.now - start_time).to_s + " seconds")
  return result
end

#Dir["/Users/hcatlin/.rvm/*"].each do |path|
rubies.each do |path|
  $version = path
  
  path = "/Users/hcatlin/.rvm/" + path
  ruby = path + "/bin/ruby"
  
  begin
    v = Version.new(ruby)
    v.install
    if v.boot
    else
      Log.error("#{path} didn't launch!")
    end
  ensure
    v.shutdown
  end
end