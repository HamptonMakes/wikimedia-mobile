# This isn't technically a Bundler gemfile anymore...
# To install these gems, run bin/install_gems

merb_gems_version = "1.1"
dm_gems_version   = "0.10.1"
do_gems_version   = "0.10.0"

# Set bundle path to ./gems. use the "gem bundle" command to generate the bundle
#bundle_path("tmp/" + RUBY_RELEASE_DATE)
#source "http://edge.merbivore.com"

gem "memcache-client", "1.7.5", :require_as => []
gem "curb", "0.5.4.0"
gem "nokogiri", "1.3.3"
gem "gchartrb", nil, :require_as => "google_chart"
gem "sinatra", "0.9.4"
gem "mime-types", nil, :require_as => "mime/types"
gem "moneta", "0.6.0"
gem "json_pure"

#gem "dm-core", dm_gems_version
#gem "do_mysql", ""

gem "thin"

gem "merb-core",        merb_gems_version
gem "merb-assets",      merb_gems_version
gem "merb-cache",       merb_gems_version
gem "merb-haml",        merb_gems_version
gem "merb-mailer",      merb_gems_version
gem "merb-exceptions",  merb_gems_version

#only :test do
  
  gem "rake"
  gem "webrat"
  gem "rspec"
#end
