# -*- encoding: utf-8 -*-
require File.expand_path('../lib/feedjira/version', __FILE__)

Gem::Specification.new do |s|
  s.authors  = ['Paul Dix', 'Julien Kirch', 'Ezekiel Templin', 'Jon Allured']
  s.email    = 'feedjira@gmail.com'
  s.homepage = 'http://feedjira.com'
  s.license  = 'MIT'
  s.name     = 'feedjira'
  s.platform = Gem::Platform::RUBY
  s.summary  = 'A feed fetching and parsing library'
  s.version  = Feedjira::VERSION

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.required_ruby_version = '>=1.9.3'

  s.add_dependency 'faraday',            '>= 0.9'
  s.add_dependency 'faraday_middleware', '>= 0.9'
  s.add_dependency 'loofah',             '>= 2.0'
  s.add_dependency 'sax-machine',        '>= 1.0'

  s.add_development_dependency 'danger'
  s.add_development_dependency 'danger-commit_lint'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop', '0.46'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'yard', '~> 0.9'
end
