# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: fire-model 0.0.18 ruby lib

Gem::Specification.new do |s|
  s.name = "fire-model"
  s.version = "0.0.18"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Vitaly Tarasenko"]
  s.date = "2015-07-01"
  s.description = "You can define your Firebase models, set collection names, CRUD your data.  "
  s.email = "vetal.tarasenko@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "fire-model.gemspec",
    "lib/connection/request.rb",
    "lib/connection/response.rb",
    "lib/fire-model.rb",
    "lib/model/base.rb",
    "lib/model/nested/base.rb",
    "lib/model/nested/parent.rb",
    "lib/model/nested/single.rb",
    "lib/model/querying/querying.rb",
    "lib/support/fire_logger.rb",
    "spec/models/main_spec.rb",
    "spec/models/nested_models_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/tarvit/fire-model"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Simple library for Firebase"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tarvit-helpers>, ["~> 0.0.5"])
      s.add_runtime_dependency(%q<httpclient>, ["~> 2.6"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<rspec>, ["~> 3.2"])
      s.add_development_dependency(%q<pry>, ["~> 0.10.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<tarvit-helpers>, ["~> 0.0.5"])
      s.add_dependency(%q<httpclient>, ["~> 2.6"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<rspec>, ["~> 3.2"])
      s.add_dependency(%q<pry>, ["~> 0.10.1"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<tarvit-helpers>, ["~> 0.0.5"])
    s.add_dependency(%q<httpclient>, ["~> 2.6"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<rspec>, ["~> 3.2"])
    s.add_dependency(%q<pry>, ["~> 0.10.1"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

