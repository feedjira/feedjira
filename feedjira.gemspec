# -*- encoding: utf-8 -*-

require File.expand_path("lib/feedjira/version", __dir__)

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |s|
  s.authors = [
    "Adam Hess",
    "Ezekiel Templin",
    "Jon Allured",
    "Julien Kirch",
    "Michael Stock",
    "Paul Dix"
  ]
  s.email    = "feedjira@gmail.com"
  s.homepage = "http://feedjira.com"
  s.license  = "MIT"
  s.name     = "feedjira"
  s.platform = Gem::Platform::RUBY
  s.summary  = "A feed parsing library"
  s.version  = Feedjira::VERSION

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.required_ruby_version = ">=2.2"

  s.add_dependency "loofah",             ">= 2.0"
  s.add_dependency "sax-machine",        ">= 1.0"

  s.add_development_dependency "danger"
  s.add_development_dependency "danger-commit_lint"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "vcr"
  s.add_development_dependency "yard"
end
# rubocop:enable Metrics/BlockLength
