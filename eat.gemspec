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
  s.summary     = %q{Defines an #eat method that takes local and remote paths and returns the contents it finds there as a String. Like open-uri but with fewer weirdnesses (and it doesn't override #open).}
  s.description = %q{A (better?) replacement for open-uri. Gets the contents of local and remote files as a String, no questions asked.}

  s.rubyforge_project = "eat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_development_dependency 'test-unit'
end
