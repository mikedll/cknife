# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: cknife 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "cknife"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Mike De La Loza"]
  s.date = "2014-06-06"
  s.description = "An Amazon Web Services S3 command line tool, and a few other command line tools."
  s.email = "mikedll@mikedll.com"
  s.executables = ["cknifeaws", "cknifedub", "cknifenowtimestamp", "cknifewcdir", "cknifezerigo"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/cknifeaws",
    "bin/cknifedub",
    "bin/cknifenowtimestamp",
    "bin/cknifewcdir",
    "bin/cknifezerigo",
    "cknife.gemspec"
  ]
  s.homepage = "http://github.com/mikedll/cali-army-knife"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Cali Army Knife"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.6.3"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6.0"])
      s.add_runtime_dependency(%q<i18n>, ["~> 0.6.0"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.7"])
      s.add_runtime_dependency(%q<thor>, ["~> 0.14.6"])
      s.add_runtime_dependency(%q<builder>, ["~> 3.0.0"])
      s.add_runtime_dependency(%q<fog>, [">= 1.15.0"])
      s.add_runtime_dependency(%q<unf>, ["~> 0.1.3"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
    else
      s.add_dependency(%q<rest-client>, ["~> 1.6.3"])
      s.add_dependency(%q<nokogiri>, ["~> 1.6.0"])
      s.add_dependency(%q<i18n>, ["~> 0.6.0"])
      s.add_dependency(%q<activesupport>, ["~> 3.0.7"])
      s.add_dependency(%q<thor>, ["~> 0.14.6"])
      s.add_dependency(%q<builder>, ["~> 3.0.0"])
      s.add_dependency(%q<fog>, [">= 1.15.0"])
      s.add_dependency(%q<unf>, ["~> 0.1.3"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    end
  else
    s.add_dependency(%q<rest-client>, ["~> 1.6.3"])
    s.add_dependency(%q<nokogiri>, ["~> 1.6.0"])
    s.add_dependency(%q<i18n>, ["~> 0.6.0"])
    s.add_dependency(%q<activesupport>, ["~> 3.0.7"])
    s.add_dependency(%q<thor>, ["~> 0.14.6"])
    s.add_dependency(%q<builder>, ["~> 3.0.0"])
    s.add_dependency(%q<fog>, [">= 1.15.0"])
    s.add_dependency(%q<unf>, ["~> 0.1.3"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
  end
end
