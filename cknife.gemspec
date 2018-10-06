# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: cknife 1.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "cknife"
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Rivera"]
  s.date = "2016-03-02"
  s.description = "A collection of command line tools, especially for popular API services."
  s.email = "soymrmike@gmail.com"
  s.executables = ["cknifeaws", "cknifedub", "cknifemail", "cknifemon", "cknifemysql", "cknifenowtimestamp", "cknifepg", "cknifewcdir", "cknifezerigo"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".ruby-gemset",
    ".ruby-version",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/cknifeaws",
    "bin/cknifedub",
    "bin/cknifemail",
    "bin/cknifemon",
    "bin/cknifemysql",
    "bin/cknifenowtimestamp",
    "bin/cknifepg",
    "bin/cknifewcdir",
    "bin/cknifezerigo",
    "cknife.gemspec",
    "cknife.yml.sample",
    "lib/cknife/backgrounded_polling.rb",
    "lib/cknife/cknife_aws.rb",
    "lib/cknife/cknife_mon.rb",
    "lib/cknife/cknife_mysql.rb",
    "lib/cknife/cknife_pg.rb",
    "lib/cknife/command_line.rb",
    "lib/cknife/config.rb",
    "lib/cknife/monitor.rb",
    "lib/cknife/repetition.rb"
  ]
  s.homepage = "http://github.com/mikedll/cknife"
  s.licenses = [""]
  s.rubygems_version = "2.4.7"
  s.summary = "CKnife"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 1.6", "~> 1"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.6", "~> 1"])
      s.add_runtime_dependency(%q<i18n>, ["~> 0"])
      s.add_runtime_dependency(%q<activesupport>, ["> 3"])
      s.add_runtime_dependency(%q<actionpack>, ["> 3"])
      s.add_runtime_dependency(%q<mail>, ["~> 2.4"])
      s.add_runtime_dependency(%q<thor>, [">= 0.14", "~> 0"])
      s.add_runtime_dependency(%q<builder>, ["~> 3.0"])
      s.add_runtime_dependency(%q<fog-aws>, [">= 0"])
      s.add_runtime_dependency(%q<unf>, [">= 0.1", "~> 0"])
      s.add_runtime_dependency(%q<daemons>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
    else
      s.add_dependency(%q<rest-client>, [">= 1.6", "~> 1"])
      s.add_dependency(%q<nokogiri>, [">= 1.6", "~> 1"])
      s.add_dependency(%q<i18n>, ["~> 0"])
      s.add_dependency(%q<activesupport>, ["> 3"])
      s.add_dependency(%q<actionpack>, ["> 3"])
      s.add_dependency(%q<mail>, ["~> 2.4"])
      s.add_dependency(%q<thor>, [">= 0.14", "~> 0"])
      s.add_dependency(%q<builder>, ["~> 3.0"])
      s.add_dependency(%q<fog-aws>, [">= 0"])
      s.add_dependency(%q<unf>, [">= 0.1", "~> 0"])
      s.add_dependency(%q<daemons>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 1.6", "~> 1"])
    s.add_dependency(%q<nokogiri>, [">= 1.6", "~> 1"])
    s.add_dependency(%q<i18n>, ["~> 0"])
    s.add_dependency(%q<activesupport>, ["> 3"])
    s.add_dependency(%q<actionpack>, ["> 3"])
    s.add_dependency(%q<mail>, ["~> 2.4"])
    s.add_dependency(%q<thor>, [">= 0.14", "~> 0"])
    s.add_dependency(%q<builder>, ["~> 3.0"])
    s.add_dependency(%q<fog-aws>, [">= 0"])
    s.add_dependency(%q<unf>, [">= 0.1", "~> 0"])
    s.add_dependency(%q<daemons>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
  end
end

