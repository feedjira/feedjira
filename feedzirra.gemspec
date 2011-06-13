# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'feedzirra/version'

Gem::Specification.new do |s|
  s.name    = 'feedzirra'
  s.version = Feedzirra::VERSION

  s.authors  = ['Paul Dix']
  s.date     = '2009-02-19'
  s.email    = 'paul@pauldix.net'
  s.homepage = 'http://github.com/pauldix/feedzirra'

  s.summary     = 'A feed fetching and parsing library'
  s.description = 'A feed fetching and parsing library that treats the internet like Godzilla treats Japan: it dominates and eats all.'

  s.require_paths = ['lib']
  s.files         = Dir['{lib/spec}/**/*.rb'] + %w[README.textile Rakefile .rspec]
  s.test_files    = Dir['spec/**/*.rb']

  s.platform = Gem::Platform::RUBY

  s.add_runtime_dependency 'nokogiri',      ['> 0.0.0']
  s.add_runtime_dependency 'sax-machine',   ['>= 0.0.12']
  s.add_runtime_dependency 'curb',          ['>= 0.2.3']
  s.add_runtime_dependency 'builder',       ['>= 2.1.2']
  s.add_runtime_dependency 'activesupport', ['>=2.3.8']
  s.add_runtime_dependency 'loofah',        ['>= 0.3.1']

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'diff-lcs'
end
