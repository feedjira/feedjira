# -*- encoding: utf-8 -*-
require File.expand_path('../lib/feedzirra/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'feedzirra'
  s.version = Feedzirra::VERSION

  s.authors  = ['Paul Dix', 'Julien Kirch', "Ezekiel Templin"]
  s.email    = 'feedzirra@googlegroups.com'
  s.homepage = 'http://github.com/pauldix/feedzirra'

  s.summary     = 'A feed fetching and parsing library'
  s.description = 'A feed fetching and parsing library that treats the internet like Godzilla treats Japan: it dominates and eats all.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
  
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'nokogiri',          '~> 1.5.3'
  s.add_dependency 'sax-machine',       '~> 0.2.0.rc1'
  s.add_dependency 'curb',              '~> 0.8.0'
  s.add_dependency 'loofah',            '~> 1.2.1'

  s.add_development_dependency 'rspec', '~> 2.10.0'
end
