namespace :lang do
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