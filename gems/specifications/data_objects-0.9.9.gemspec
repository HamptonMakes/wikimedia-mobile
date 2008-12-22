# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{data_objects}
  s.version = "0.9.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yehuda Katz"]
  s.date = %q{2008-11-27}
  s.description = %q{The Core DataObjects class}
  s.email = ["wycats@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = [".gitignore", "History.txt", "LICENSE", "Manifest.txt", "README.txt", "Rakefile", "TODO", "lib/data_objects.rb", "lib/data_objects/command.rb", "lib/data_objects/connection.rb", "lib/data_objects/field.rb", "lib/data_objects/logger.rb", "lib/data_objects/quoting.rb", "lib/data_objects/reader.rb", "lib/data_objects/result.rb", "lib/data_objects/support/pooling.rb", "lib/data_objects/transaction.rb", "lib/data_objects/uri.rb", "lib/data_objects/version.rb", "spec/command_spec.rb", "spec/connection_spec.rb", "spec/dataobjects_spec.rb", "spec/do_mock.rb", "spec/reader_spec.rb", "spec/result_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/support/pooling_spec.rb", "spec/transaction_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://rubyforge.org/projects/dorb}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dorb}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{The Core DataObjects class}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<addressable>, ["~> 2.0"])
      s.add_runtime_dependency(%q<extlib>, ["~> 0.9.8"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<addressable>, ["~> 2.0"])
      s.add_dependency(%q<extlib>, ["~> 0.9.8"])
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<addressable>, ["~> 2.0"])
    s.add_dependency(%q<extlib>, ["~> 0.9.8"])
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
