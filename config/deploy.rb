set :application, "mobile"
set :repository,  "git://github.com/hcatlin/wikimedia-mobile.git"

set :scm, :git
set :user, "deploy"
set :deploy_to, "/srv/#{application}"
$sudo_user = "hcatlin"
set :deploy_via, :remote_cache

role :web, "mobile1.wikimedia.org", "mobile2.wikimedia.org"
role :cache, "mobile1.wikimedia.org"

namespace :deploy do
  
  task :gems do
    run "cd #{release_path} && gem bundle"
  end
  
  task :restart do
    deploy.stop
    deploy.start
  end
  
  task :start do
    begin
      run "#{current_path}/bin/cluster start"
    rescue
      retry
    end
  end
  
  task :before_finalize_update do
    deploy.gems
  end
  
  task :stop do
    begin
      run "#{current_path}/bin/cluster stop"
    rescue
    end
  end
end

namespace :manage do
  # Login as whoever you need to-- but someone with sudo
  #
  task :as_sudo_user do
    unset :user
    set :user, $sudo_user
  end
  
  task :as_deploy do
    unset :user
    set :user, "deploy"
  end

  desc "Build an entire server"
  task :build do
    as_sudo_user

    apt_install
    install_ruby

    setup_deploy_user

    deploy.setup
    sudo "chown -R deploy:deploy /srv/*"

    #  Need a fresh env to run as deploy
    `cap deploy:update`

    configure
  end
  
  task :apt_install do
    sudo "apt-get -y install build-essential libxml2-dev libxslt1-dev libmemcache-dev memcached zlib1g-dev libcurl4-openssl-dev libmysqlclient15-dev libncurses5 libreadline5-dev libsqlite3-dev curl wget git-core gzip nginx"
  end
  
  task :install_ruby do
    sudo(%|wget -q ftp://ftp.ruby-lang.org//pub/ruby/ruby-1.9-stable.tar.gz
      tar -xf ruby-1.9-stable.tar.gz
      cd ruby-1.9.1*
      ./configure --program-prefix=mobile-
      make
      make install
      cd ..
      wget -q http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
      tar -xf rubygems-1.3.5.tgz
      cd rubygems-1.3.5
      mobile-ruby setup.rb|.split("\n").join(";"))
    sudo "mobile-gem install bundler"
  end

  desc "Create the deploy user"
  task :setup_deploy_user do
    as_sudo_user
    #sudo "useradd -m deploy"
    #sudo "mkdir ~deploy/.ssh"
    sudo "wget -q http://github.com/hcatlin/wikimedia-mobile/raw/master/config/deploy.keys"
    sudo "mv deploy.keys ~deploy/.ssh/authorized_keys"
    sudo "chown -R deploy ~deploy/.ssh"
  end

  # Can be run as often as you like
  desc("Configure the server, can be re-run often if you like")
  task :configure do
    as_sudo_user
    sudo "rm -rf /etc/nginx/sites-enabled/*"
    run "echo 'include #{current_path}/config/nginx.site.conf;' > tmp.conf"
    sudo "mv tmp.conf /etc/nginx/sites-enabled/reference"
    sudo "ln -fs /etc/init.d/thin /srv/mobile/current/bin/thin"
    sudo "ln -fs /etc/init.d/cluster /srv/mobile/current/bin/cluster"
  end
end