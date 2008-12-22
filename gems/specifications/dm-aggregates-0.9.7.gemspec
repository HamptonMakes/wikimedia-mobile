# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-aggregates}
  s.version = "0.9.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Foy Savas"]
  s.date = %q{2008-11-18}
  s.description = %q{DataMapper plugin providing support for aggregates, functions on collections and datasets}
  s.email = ["foysavas@gmail.com"]
  s.extra_rdoc_files = ["README.txt", "LICENSE", "TODO"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "README.txt", "Rakefile", "TODO", "lib/dm-aggregates.rb", "lib/dm-aggregates/adapters/data_objects_adapter.rb", "lib/dm-aggregates/aggregate_functions.rb", "lib/dm-aggregates/collection.rb", "lib/dm-aggregates/model.rb", "lib/dm-aggregates/repository.rb", "lib/dm-aggregates/support/symbol.rb", "lib/dm-aggregates/version.rb", "spec/integration/aggregates_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/sam/dm-more/tree/master/dm-aggregates}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{datamapper}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{DataMapper plugin providing support for aggregates, functions on collections and datasets}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["= 0.9.7"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<dm-core>, ["= 0.9.7"])
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<dm-core>, ["= 0.9.7"])
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
