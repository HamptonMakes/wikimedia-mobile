require 'code_statistics'

def define_test_task(test_type)
  desc "Run the #{test_type} tests in test/#{test_type}s"
  Rake::TestTask.new "#{test_type}s" => [ 'db:test:prepare' ] do |t|
    t.libs << 'test'
    t.pattern = "test/#{test_type}s/**/*_test.rb"
    t.verbose = true
  end
end

namespace :test do
  define_test_task 'helper'
  define_test_task 'view'
  define_test_task 'controller'
end

desc 'Run all tests'
task :test => %w[
  test:units
  test:controllers
  test:helpers
  test:views
  test:functionals
  test:integration
]

dirs = [
  %w[Libraries          lib/],
  %w[Models             app/models],
  %w[Unit\ tests        test/unit],
  %w[Helpers            app/helpers],
  %w[Helper\ tests      test/helpers],
  %w[Components         components],
  %w[Controllers        app/controllers],
  %w[Controller\ tests  test/controllers],
  %w[View\ tests        test/views],
  %w[Functional\ tests  test/functional],
  %w[Integration\ tests test/integration],
  %w[APIs               app/apis],
]

dirs = dirs.map { |name, dir| [name, File.join(RAILS_ROOT, dir)] }
dirs = dirs.select { |name, dir| File.directory? dir }

STATS_DIRECTORIES.replace dirs

new_test_types = ['Controller tests', 'Helper tests', 'View tests']
CodeStatistics::TEST_TYPES.push(*new_test_types)

