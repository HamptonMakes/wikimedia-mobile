
source :gemcutter
#source "http://edge.merbivore.com"

merb_gems_version = "1.1.3"

gem "dalli"
gem "nokogiri", "1.11.4"
gem "mime-types", :require => "mime/types"
gem "json"
gem "haml"
gem "curb"

gem "merb-core",        merb_gems_version
gem "merb-assets",      merb_gems_version
gem "merb-haml",        merb_gems_version

gem "rake"

group :development do
  gem "thin"                       # for local development
  gem "typhoeus"                   # for language import rake task
end

group :test do
  gem "rspec", "2.0"#, "~> 1.3"
  gem "webrat"
  gem 'mocha'
end

# Only for the production servers
if RUBY_VERSION == "1.9.1" && RUBY_PLATFORM.include?("linux")
  gem "bundler", "0.9.5"
end