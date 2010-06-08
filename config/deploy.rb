set :application, "mobile"
set :repository,  "git://github.com/hcatlin/wikimedia-mobile.git"
set :branch, "stable"

set :scm, :git
set :user, "deploy"
set :deploy_to, "/srv/#{application}"
set :branch, "stable"

set :use_sudo, false

role :app, "mobile1.wikimedia.org", "mobile2.wikimedia.org"

namespace :deploy do

  task :gems do
    run "cd #{current_path} && /var/lib/gems/1.9.1/bin/bundle install"
  end

  task :after_update do
    gems
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