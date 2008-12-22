# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-validations}
  s.version = "0.9.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guy van den Berg"]
  s.date = %q{2008-11-18}
  s.description = %q{DataMapper plugin for performing validations on data models}
  s.email = ["vandenberg.guy@gmail.com"]
  s.extra_rdoc_files = ["README.txt", "LICENSE", "TODO"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "README.txt", "Rakefile", "TODO", "lib/dm-validations.rb", "lib/dm-validations/absent_field_validator.rb", "lib/dm-validations/acceptance_validator.rb", "lib/dm-validations/auto_validate.rb", "lib/dm-validations/block_validator.rb", "lib/dm-validations/confirmation_validator.rb", "lib/dm-validations/contextual_validators.rb", "lib/dm-validations/custom_validator.rb", "lib/dm-validations/format_validator.rb", "lib/dm-validations/formats/email.rb", "lib/dm-validations/formats/url.rb", "lib/dm-validations/generic_validator.rb", "lib/dm-validations/length_validator.rb", "lib/dm-validations/method_validator.rb", "lib/dm-validations/numeric_validator.rb", "lib/dm-validations/primitive_validator.rb", "lib/dm-validations/required_field_validator.rb", "lib/dm-validations/support/object.rb", "lib/dm-validations/uniqueness_validator.rb", "lib/dm-validations/validation_errors.rb", "lib/dm-validations/version.rb", "lib/dm-validations/within_validator.rb", "spec/integration/absent_field_validator_spec.rb", "spec/integration/acceptance_validator_spec.rb", "spec/integration/auto_validate_spec.rb", "spec/integration/block_validator_spec.rb", "spec/integration/confirmation_validator_spec.rb", "spec/integration/contextual_validators_spec.rb", "spec/integration/custom_validator_spec.rb", "spec/integration/format_validator_spec.rb", "spec/integration/generic_validator_spec.rb", "spec/integration/length_validator_spec.rb", "spec/integration/method_validator_spec.rb", "spec/integration/numeric_validator_spec.rb", "spec/integration/primitive_validator_spec.rb", "spec/integration/required_field_validator_spec.rb", "spec/integration/uniqueness_validator_spec.rb", "spec/integration/validation_errors_spec.rb", "spec/integration/validation_spec.rb", "spec/integration/within_validator_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/sam/dm-more/tree/master/dm-validations}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{datamapper}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{DataMapper plugin for performing validations on data models}

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
