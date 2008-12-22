# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{merb}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Merb Team"]
  s.date = %q{2008-11-25}
  s.description = %q{(merb-core + merb-more + DM) == Merb stack}
  s.email = %q{team@merbivore.com}
  s.files = ["LICENSE", "README", "Rakefile", "lib/merb.rb"]
  s.homepage = %q{http://merbivore.com/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{(merb-core + merb-more + DM) == Merb stack}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb-core>, ["~> 1.0.3"])
      s.add_runtime_dependency(%q<merb-more>, ["~> 1.0.3"])
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.9.7"])
      s.add_runtime_dependency(%q<do_sqlite3>, ["~> 0.9.7"])
      s.add_runtime_dependency(%q<dm-timestamps>, ["~> 0.9.7"])
      s.add_runtime_dependency(%q<dm-types>, ["~> 0.9.7"])
      s.add_runtime_dependency(%q<dm-aggregates>, ["~> 0.9.7"])
      s.add_runtime_dependency(%q<dm-migrations>, ["~> 0.9.7"])
      s.add_runtime_dependency(%q<dm-validations>, ["~> 0.9.7"])
      s.add_runtime_dependency(%q<dm-sweatshop>, ["~> 0.9.7"])
    else
      s.add_dependency(%q<merb-core>, ["~> 1.0.3"])
      s.add_dependency(%q<merb-more>, ["~> 1.0.3"])
      s.add_dependency(%q<dm-core>, ["~> 0.9.7"])
      s.add_dependency(%q<do_sqlite3>, ["~> 0.9.7"])
      s.add_dependency(%q<dm-timestamps>, ["~> 0.9.7"])
      s.add_dependency(%q<dm-types>, ["~> 0.9.7"])
      s.add_dependency(%q<dm-aggregates>, ["~> 0.9.7"])
      s.add_dependency(%q<dm-migrations>, ["~> 0.9.7"])
      s.add_dependency(%q<dm-validations>, ["~> 0.9.7"])
      s.add_dependency(%q<dm-sweatshop>, ["~> 0.9.7"])
    end
  else
    s.add_dependency(%q<merb-core>, ["~> 1.0.3"])
    s.add_dependency(%q<merb-more>, ["~> 1.0.3"])
    s.add_dependency(%q<dm-core>, ["~> 0.9.7"])
    s.add_dependency(%q<do_sqlite3>, ["~> 0.9.7"])
    s.add_dependency(%q<dm-timestamps>, ["~> 0.9.7"])
    s.add_dependency(%q<dm-types>, ["~> 0.9.7"])
    s.add_dependency(%q<dm-aggregates>, ["~> 0.9.7"])
    s.add_dependency(%q<dm-migrations>, ["~> 0.9.7"])
    s.add_dependency(%q<dm-validations>, ["~> 0.9.7"])
    s.add_dependency(%q<dm-sweatshop>, ["~> 0.9.7"])
  end
end
