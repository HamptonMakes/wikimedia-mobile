
source :gemcutter
#source "http://edge.merbivore.com"

merb_gems_version = "1.1.0"

gem "dalli"
gem "nokogiri", "1.3.3"
gem "mime-types", :require => "mime/types"
gem "json"
gem "typhoeus"
gem "haml"
gem "abstract"
gem "curb"

#gem "do_mysql", :bundle => false
#gem "mysql", :bundle => false

gem "merb-core",        merb_gems_version
gem "merb-assets",      merb_gems_version
gem "merb-cache",       merb_gems_version
gem "merb-haml",        merb_gems_version
gem "merb-mailer",      merb_gems_version
#gem "merb-exceptions",  merb_gems_version

gem "rake"
gem "rspec"

group :development do
  gem "thin"
  gem "moneta"
end

# Only for the production servers
if RUBY_VERSION == "1.9.1" && RUBY_PLATFORM.include?("linux")
  gem "bundler", "0.9.5"
end