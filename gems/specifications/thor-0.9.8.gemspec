# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thor}
  s.version = "0.9.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yehuda Katz"]
  s.date = %q{2008-10-20}
  s.description = %q{A gem that maps options to a class}
  s.email = %q{wycats@gmail.com}
  s.executables = ["thor", "rake2thor"]
  s.extra_rdoc_files = ["README.markdown", "LICENSE", "CHANGELOG.rdoc"]
  s.files = ["README.markdown", "LICENSE", "CHANGELOG.rdoc", "Rakefile", "bin/rake2thor", "bin/thor", "lib/thor", "lib/thor/error.rb", "lib/thor/options.rb", "lib/thor/ordered_hash.rb", "lib/thor/runner.rb", "lib/thor/task.rb", "lib/thor/task_hash.rb", "lib/thor/tasks", "lib/thor/tasks/package.rb", "lib/thor/tasks.rb", "lib/thor/util.rb", "lib/thor.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://yehudakatz.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{thor}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{A gem that maps options to a class}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
