# frozen_string_literal: true

require File.expand_path("lib/feedjira/version", __dir__)

Gem::Specification.new do |s|
  s.authors = [
    "Adam Hess",
    "Akinori Musha",
    "Ezekiel Templin",
    "Jon Allured",
    "Julien Kirch",
    "Michael Stock",
    "Paul Dix"
  ]
  s.homepage = "https://github.com/feedjira/feedjira"
  s.license  = "MIT"
  s.name     = "feedjira"
  s.platform = Gem::Platform::RUBY
  s.summary  = "A feed parsing library"
  s.version  = Feedjira::VERSION

  s.metadata = {
    "homepage_uri" => "http://feedjira.com",
    "source_code_uri" => "https://github.com/feedjira/feedjira",
    "changelog_uri" => "https://github.com/feedjira/feedjira/blob/master/CHANGELOG.md"
  }

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.required_ruby_version = ">=2.5"

  s.add_dependency "loofah",             ">= 2.3.1"
  s.add_dependency "sax-machine",        ">= 1.0"

  s.add_development_dependency "faraday"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "vcr"
  s.add_development_dependency "yard"
end
