# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{addressable}
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bob Aman"]
  s.date = %q{2008-12-02}
  s.description = %q{Addressable is a replacement for the URI implementation that is part of Ruby's standard library. It more closely conforms to the relevant RFCs and adds support for IRIs and URI templates.}
  s.email = %q{bob@sporkmonger.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/addressable", "lib/addressable/idna.rb", "lib/addressable/uri.rb", "lib/addressable/version.rb", "spec/addressable", "spec/addressable/idna_spec.rb", "spec/addressable/uri_spec.rb", "spec/data", "spec/data/rfc3986.txt", "tasks/clobber.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/metrics.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/spec.rake", "website/index.html", "CHANGELOG", "LICENSE", "Rakefile", "README"]
  s.has_rdoc = true
  s.homepage = %q{http://addressable.rubyforge.org/}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{addressable}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{URI Implementation}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0.7.3"])
      s.add_development_dependency(%q<rspec>, [">= 1.0.8"])
      s.add_development_dependency(%q<launchy>, [">= 0.3.2"])
    else
      s.add_dependency(%q<rake>, [">= 0.7.3"])
      s.add_dependency(%q<rspec>, [">= 1.0.8"])
      s.add_dependency(%q<launchy>, [">= 0.3.2"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.7.3"])
    s.add_dependency(%q<rspec>, [">= 1.0.8"])
    s.add_dependency(%q<launchy>, [">= 0.3.2"])
  end
end
