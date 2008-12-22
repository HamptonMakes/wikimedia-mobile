require 'rubygems'
require 'spec'
require 'spec/rake/spectask'
require 'pathname'

ROOT = Pathname(__FILE__).dirname.expand_path
require ROOT + 'lib/dm-migrations/version'

AUTHOR = "Paul Sadauskas"
EMAIL  = "psadauskas@gmail.com"
GEM_NAME = "dm-migrations"
GEM_VERSION = DataMapper::Migration::VERSION
GEM_DEPENDENCIES = [["dm-core", '~>0.9.7']]
GEM_CLEAN = ["log", "pkg"]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.txt LICENSE TODO ] }

PROJECT_NAME = "datamapper"
PROJECT_URL  = "http://github.com/sam/dm-more/tree/master/dm-migrations"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = "DataMapper plugin for writing and speccing migrations"

require ROOT.parent + 'tasks/hoe'

task :default => [ :spec ]

WIN32 = (RUBY_PLATFORM =~ /win32|mingw|cygwin/) rescue nil
SUDO  = WIN32 ? '' : ('sudo' unless ENV['SUDOLESS'])

desc "Install #{GEM_NAME} #{GEM_VERSION} (default ruby)"
task :install => [ :package ] do
  sh "#{SUDO} gem install --local pkg/#{GEM_NAME}-#{GEM_VERSION} --no-update-sources", :verbose => false
end

desc "Uninstall #{GEM_NAME} #{GEM_VERSION} (default ruby)"
task :uninstall => [ :clobber ] do
  sh "#{SUDO} gem uninstall #{GEM_NAME} -v#{GEM_VERSION} -I -x", :verbose => false
end

namespace :jruby do
  desc "Install #{GEM_NAME} #{GEM_VERSION} with JRuby"
  task :install => [ :package ] do
    sh %{#{SUDO} jruby -S gem install --local pkg/#{GEM_NAME}-#{GEM_VERSION} --no-update-sources}, :verbose => false
  end
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts << '--options' << 'spec/spec.opts' if File.exists?('spec/spec.opts')
  t.spec_files = Pathname.glob((ROOT + 'spec/**/*_spec.rb').to_s)

  begin
    t.rcov = ENV.has_key?('NO_RCOV') ? ENV['NO_RCOV'] != 'true' : true
    t.rcov_opts << '--exclude' << 'spec'
    t.rcov_opts << '--text-summary'
    t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
  rescue Exception
    # rcov not installed
  end
end

namespace :db do

  # pass the relative path to the migrations directory by MIGRATION_DIR
  task :setup_migration_dir do
    unless defined?(MIGRATION_DIR)
      migration_dir = ENV["MIGRATION_DIR"] || File.join("db", "migrations")
      MIGRATION_DIR = File.expand_path(File.join(File.dirname(__FILE__), migration_dir))
    end
    FileUtils.mkdir_p MIGRATION_DIR
  end

  # set DIRECTION to migrate down
  desc "Run your system's migrations"
  task :migrate => [:setup_migration_dir] do
    require File.expand_path(File.join(File.dirname(__FILE__), "lib", "migration_runner.rb"))
    require File.expand_path(File.join(MIGRATION_DIR, "config.rb"))

    Dir[File.join(MIGRATION_DIR, "*.rb")].each { |file| require file }

    ENV["DIRECTION"] != "down" ? migrate_up! : migrate_down!
  end
end
