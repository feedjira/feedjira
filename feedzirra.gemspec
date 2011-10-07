# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'feedzirra/version'

Gem::Specification.new do |s|
  s.name    = 'feedzirra'
  s.version = Feedzirra::VERSION

  s.authors  = ['Paul Dix', 'Julien Kirch']
  s.date     = '2011-09-30'
  s.email    = 'feedzirra@googlegroups.com'
  s.homepage = 'http://github.com/pauldix/feedzirra'

  s.summary     = 'A feed fetching and parsing library'
  s.description = 'A feed fetching and parsing library that treats the internet like Godzilla treats Japan: it dominates and eats all.'

  s.require_paths = ['lib']
  s.files         = Dir['{lib,spec}/**/*.rb'] + %w[README.rdoc Rakefile .rspec]
  s.test_files    = Dir['spec/**/*.rb']

  s.platform = Gem::Platform::RUBY

  s.add_runtime_dependency 'nokogiri',      ['>= 1.4.4']
  s.add_runtime_dependency 'sax-machine',   ['~> 0.1.0']
  s.add_runtime_dependency 'curb',          ['~> 0.7.15']
  s.add_runtime_dependency 'builder',       ['~> 2.1.2']
  s.add_runtime_dependency 'activesupport', ['>= 3.0.8']
  s.add_runtime_dependency 'loofah',        ['~> 1.2.0']
  s.add_runtime_dependency 'rdoc',          ['~> 3.8']
  s.add_runtime_dependency 'rake',          ['>= 0.9.2']
  s.add_runtime_dependency 'i18n',          ['>= 0.5.0']

  s.add_development_dependency 'rspec',     ['~> 2.6.0']
end
