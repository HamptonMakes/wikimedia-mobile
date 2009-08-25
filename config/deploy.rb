set :application, "mobile"
set :repository,  "git://github.com/hcatlin/wikimedia-mobile.git"

set :scm, :git
set :user, "deploy"
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
    run "/etc/init.d/thin stop"
  end
end