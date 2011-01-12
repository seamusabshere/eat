# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "eat/version"

Gem::Specification.new do |s|
  s.name        = "eat"
  s.version     = Eat::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Seamus Abshere"]
  s.email       = ["seamus@abshere.net"]
  s.homepage    = "https://github.com/seamusabshere/eat"
  s.summary     = %q{A more trustworthy open-uri for use with RSS feeds, config scripts, etc.}
  s.description = %q{Lets you open local and remote files by immediately returning their contents as a string.}

  s.rubyforge_project = "eat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_development_dependency 'test-unit'
end
