# -*- encoding: utf-8 -*-
require File.expand_path('../lib/feedjira/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'feedjira'
  s.version = Feedjira::VERSION
  s.license = 'MIT'

  s.authors  = ['Paul Dix', 'Julien Kirch', 'Ezekiel Templin', 'Jon Allured']
  s.email    = 'feedjira@gmail.com'
  s.homepage = 'http://feedjira.com'

  s.summary     = 'A feed fetching and parsing library'
  s.description = 'A library designed to retrieve and parse feeds as quickly as possible'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.platform = Gem::Platform::RUBY

  s.add_dependency 'sax-machine', '>= 0.2.1', '< 1.1.0'
  s.add_dependency 'curb',        '~> 0.8.1'
  s.add_dependency 'loofah',      '~> 2.0.0'

  s.add_development_dependency 'rspec', '~> 2.14.0'
end
