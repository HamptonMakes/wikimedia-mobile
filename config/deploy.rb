set :application, "mobile"
set :repository,  "git://github.com/hcatlin/wikimedia-mobile.git"

set :scm, :git
set :user, "deploy"
set :deploy_to, "/srv/#{application}"

role :web, "mobile1.wikimedia.org"
role :cache, "mobile1.wikimedia.org"

namespace :deploy do
  
  task :gems do
    run "cd #{current_path} && gem bundle"
  end
  
  task :restart do
    deploy.gems
    deploy.stop
    deploy.start
  end
  
  task :start do
    begin
      run "/etc/init.d/cluster start"
    rescue
      retry
    end
  end
  
  task :stop do
    begin
      run "/etc/init.d/cluster stop"
    rescue
    end
  end
end