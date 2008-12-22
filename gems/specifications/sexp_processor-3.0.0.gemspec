# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sexp_processor}
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Davis"]
  s.date = %q{2008-10-22}
  s.description = %q{FIX (describe your package)}
  s.email = ["ryand-ruby@zenspider.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/composite_sexp_processor.rb", "lib/sexp.rb", "lib/sexp_processor.rb", "test/test_composite_sexp_processor.rb", "test/test_environment.rb", "test/test_sexp.rb", "test/test_sexp_processor.rb"]
  s.has_rdoc = true
  s.homepage = %q{FIX (url)}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{parsetree}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{FIX (describe your package)}
  s.test_files = ["test/test_composite_sexp_processor.rb", "test/test_environment.rb", "test/test_sexp.rb", "test/test_sexp_processor.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
