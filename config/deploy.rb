set :application, "mobile"
set :repository,  "git://github.com/hcatlin/wikimedia-mobile.git"
set :branch, "stable"

set :scm, :git
set :user, "deploy"
set :deploy_to, "/srv/#{application}"
set :branch, "stable"

set :use_sudo, false

role :app, "mobile1.wikimedia.org", "mobile2.wikimedia.org", "mobile3.wikimedia.org"

bin = "/var/lib/gems/1.9.1/bin"

namespace :deploy do

  after "deploy:update_code" do
    #run "cp #{previous_release}/Gemfile.lock #{current_release}"
    run "cd #{current_release} && #{bin}/bundle install"
  end
  
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

namespace :passenger do
  task :memory_stats do
    run "passenger-memory-stats"
  end
end