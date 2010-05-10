
source :gemcutter
#source "http://edge.merbivore.com"

merb_gems_version = "1.1.0.pre"
dm_gems_version   = "0.10.1"
do_gems_version   = "0.10.0"

#disable_system_gems

gem "memcache-client", "1.7.5", :require => []
gem "curb", "0.5.4.0"
gem "nokogiri", "1.3.3"
gem "gchartrb", nil, :require => "google_chart"
gem "sinatra", "0.9.4"
gem "mime-types", nil, :require => "mime/types"
gem "moneta", "0.6.0"
gem "json_pure"
gem "typhoeus"
gem "thin"

#gem "do_mysql", :bundle => false
#gem "mysql", :bundle => false

gem "merb-core",        merb_gems_version
gem "merb-assets",      merb_gems_version
gem "merb-cache",       merb_gems_version
gem "merb-haml",        merb_gems_version
gem "merb-mailer",      merb_gems_version
gem "merb-exceptions",  merb_gems_version

if false
  # Stuff for stats
  gem "activesupport"
  gem "data_objects", do_gems_version
  gem "dm-core", dm_gems_version
  gem "dm-aggregates", dm_gems_version
end

#only :test do
  
  gem "rake"
  #gem "webrat"
  gem "rspec"
#end
