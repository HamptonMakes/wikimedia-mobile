set :application, "mobile"
set :repository,  "git://github.com/hcatlin/wikimedia-mobile.git"
set :branch, "stable"

set :scm, :git
set :user, "deploy"
set :deploy_to, "/srv/#{application}"
set :branch, "stable"

role :web, "mobile1.wikimedia.org"#, "mobile2.wikimedia.org"
role :cache, "mobile1.wikimedia.org"

namespace :deploy do
  
  task :gems do
    run "cd #{current_path} && bundle install"
  end
  
  task :after_update do
    gems
  end
  
  task :restart do
    run "#{current_path}/bin/server --onebyone -C #{current_path}/config/thins/mobile.yml restart"
  end
  
  task :start do
    begin
      run "#{current_path}/bin/server -C #{current_path}/config/thins/mobile.yml start"
    rescue
      retry
    end
  end
  
  task :stop do
    begin
      run "#{current_path}/bin/server -C #{current_path}/config/thins/mobile.yml stop"
    rescue
    end
  end
end