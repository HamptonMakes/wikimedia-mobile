namespace :lang do
  desc "Statistics"
  task :status do
    mobile_page = 0
    standardized_sections = 0
    settings = YAML::load(open("config/wikipedias.yml"))
    settings.each do |key, wiki|
      if wiki["mobile_main_page"]
        mobile_page += 1
      else
        standardized_sections += 1
      end
    end
    
    puts "#{mobile_page} Wikis with customized mobile pages"
    puts "#{standardized_sections} standardized sections"
    puts "#{settings.keys.size} total"
    
  end
  
  desc "Import and refresh all language strings"
  task :import do
    Encoding.default_internal = Encoding.default_external = "ASCII-8BIT"
    require 'nokogiri'
    require 'typhoeus'
    require 'open-uri'
    require 'yaml'
    hydra = Typhoeus::Hydra.new

    languages = Nokogiri::HTML(open("http://translatewiki.net/wiki/Translating:Wikimedia_mobile")).css("table.sortable:first tr td:first-child").to_a

    languages.each do |lang|
      
      code = lang.text
      if code =~ /^[-a-z]+$/ && code != "en"
        puts "Loading: " + code
      #begin
          r = Typhoeus::Request.new("http://translatewiki.net/w/i.php?title=Special%3ATranslate&task=export-to-file&group=out-wikimediamobile&language=#{code}")
          r.on_complete do |response|
            begin
              if response.body.size == 0
                puts "Language not supported"
              else
                file = File.open(Merb.root + "/config/translations/#{code}.yml", "w")
                file.write(response.body)
                file.close
                puts "Wrote #{response.body.size} bytes to #{code}"
              end
            #rescue
            #  puts "Error with" + response.inspect
            end
          end
          hydra.queue r
        #rescue
        #  puts "ERROR!!!"
        #end
      end
    end
    
    hydra.run
    
    #puts requests.size
  end
end