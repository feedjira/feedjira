# -*- encoding: utf-8 -*-
require File.expand_path('../lib/feedzirra/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'feedzirra'
  s.version = Feedzirra::VERSION

  s.authors  = ['Paul Dix', 'Julien Kirch', "Ezekiel Templin"]
  s.email    = 'feedzirra@googlegroups.com'
  s.homepage = 'http://github.com/pauldix/feedzirra'

  s.summary     = 'A feed fetching and parsing library'
  s.description = 'A library designed to retrieve and parse feeds as quickly as possible'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
  
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'nokogiri',          '~> 1.6.0'
  #
  # TODO Update sax-machine dependency as soon as a new version is released with the changes of this pull request: https://github.com/pauldix/sax-machine/pull/45
  # The current released version of sax-machine has a dependency for an older version of Nokogiri, causing compatibility issues.
  # 
  # Also remove temporary gem dependency in Gemfile
  #
  # s.add_dependency 'sax-machine',       '~> 0.2.0.rc1'
  s.add_dependency 'curb',              '~> 0.8.1'
  s.add_dependency 'loofah',            '~> 1.2.1'

  s.add_development_dependency 'rspec', '~> 2.13.0'
end
