merb_gems_version = "1.1"
dm_gems_version   = "0.10.1"
do_gems_version   = "0.10.0"

# Set bundle path to ./gems. use the "gem bundle" command to generate the bundle
bundle_path "gems"
source "http://edge.merbivore.com"

gem "merb-core",        merb_gems_version
gem "merb-assets",      merb_gems_version
gem "merb-cache",       merb_gems_version
gem "merb-haml",        merb_gems_version
gem "merb-mailer",      merb_gems_version
gem "merb-exceptions",  merb_gems_version


gem "memcache-client", :require_as => []
gem "curb"
gem "nokogiri"
gem "gchartrb", :require_as => "google_chart"
gem "sinatra"
gem "mime-types", :require_as => "mime/types"
gem "moneta"

only :test do
  gem "thin"
  gem "rake"
  gem "webrat"
  gem "rspec", :require_as => []
end
