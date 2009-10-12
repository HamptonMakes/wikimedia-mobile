namespace :lang do
  desc "Import and refresh all language strings"
  task :import do
    require 'nokogiri'
    require 'open-uri'
    require 'yaml'
    languages = Nokogiri::XML(open("http://en.wikipedia.org/w/api.php?action=sitematrix&format=xml")).css("language")
  
    languages.each do |lang|
      t = Thread.new do
        code = lang['code']
        if code =~ /^[a-z]+$/
          puts "Loading: " + code
          begin
            translations = open("http://translatewiki.net/w/i.php?title=Special%3ATranslate&task=export-to-file&group=out-wikimediamobile&language=#{code}").read
            if translations.size == 0
              puts "Language not supported"
            else
              data = YAML.load(translations)
              if data != nil && data.keys.size > 0
                file = File.open(Merb.root + "/config/translations/#{code}.yml", "w")
                file.write(translations)
                file.close
                puts "Wrote #{data.keys.size} keys"
              else
                puts "No translations"
              end
            end
          rescue
            puts "ERROR!!!"
          end
        end
      end
      t.join()
    end
  end
end