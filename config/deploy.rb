set :application, "wikimedia-mobile"
set :repository,  "git://github.com/hcatlin/wikimedia-mobile.git"

set :scm, :git
set :user, "root"
set :deploy_to, "/srv/#{application}"

role :web, "mobile1.wikimedia.org"
role :cache, "mobile1.wikimedia.org"

namespace :deploy do
  task :restart do
    deploy.stop
    deploy.start
  end
  
  task :start do
    run "/etc/init.d/thin start"
  end
  
  task :stop do
    run "pkill -9 thin"
  end
end