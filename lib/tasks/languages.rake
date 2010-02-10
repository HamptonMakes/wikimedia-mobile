namespace :lang do
  desc "Import and refresh all language strings"
  task :import do
    require 'nokogiri'
    require 'open-uri'
    require 'yaml'

    languages = Nokogiri::HTML(open("http://translatewiki.net/wiki/Translating:Wikimedia_mobile")).css("table.sortable:first tr td:first-child").to_a

    languages.each do |lang|
      code = lang.text
      if code =~ /^[-a-z]+$/
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
  end
end