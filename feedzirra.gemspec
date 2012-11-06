# -*- encoding: utf-8 -*-
require File.expand_path('../lib/feedzirra/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'feedzirra'
  s.version = Feedzirra::VERSION

  s.authors  = ['Paul Dix', 'Julien Kirch', "Ezekiel Templin"]
  s.date     = Date.today
  s.email    = 'feedzirra@googlegroups.com'
  s.homepage = 'http://github.com/pauldix/feedzirra'

  s.summary     = 'A feed fetching and parsing library'
  s.description = 'A feed fetching and parsing library that treats the internet like Godzilla treats Japan: it dominates and eats all.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
  
  s.platform = Gem::Platform::RUBY

<<<<<<< HEAD
  s.add_runtime_dependency 'nokogiri',      ['>= 1.4.4']
  s.add_runtime_dependency 'sax-machine',   ['~> 0.1.0']
  s.add_runtime_dependency 'curb',          ['~> 0.7.15']
  s.add_runtime_dependency 'builder',       ['>= 2.1.2']
  s.add_runtime_dependency 'activesupport', ['>= 3.1.1']
  s.add_runtime_dependency 'loofah',        ['~> 1.2.0']
  s.add_runtime_dependency 'rdoc',          ['~> 3.8']
  s.add_runtime_dependency 'rake',          ['>= 0.8.7']
  s.add_runtime_dependency 'i18n',          ['>= 0.5.0']
=======
  s.add_dependency 'nokogiri',          '~> 1.5.3'
  s.add_dependency 'sax-machine',       '~> 0.2.0.rc1'
  s.add_dependency 'curb',              '~> 0.8.0'
  s.add_dependency 'loofah',            '~> 1.2.1'
>>>>>>> 9681b630e23ec604caac5411eddbd2dc71d70806

  s.add_development_dependency 'rspec', '~> 2.10.0'
end
