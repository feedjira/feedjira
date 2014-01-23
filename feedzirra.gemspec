# -*- encoding: utf-8 -*-
require File.expand_path('../lib/feedzirra/version', __FILE__)

Gem::Specification.new do |s|
  s.post_install_message = 'This project has been renamed to Feedjira, find out more at feedjira.com.'
  s.name    = 'feedzirra'
  s.version = Feedzirra::VERSION
  s.license = 'MIT'

  s.authors  = ['Paul Dix', 'Julien Kirch', 'Ezekiel Templin', 'Jon Allured']
  s.email    = 'feedzirra@googlegroups.com'
  s.homepage = 'http://github.com/pauldix/feedzirra'

  s.summary     = 'A feed fetching and parsing library'
  s.description = 'This project has been renamed to Feedjira, find out more at feedjira.com.'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']

  s.platform = Gem::Platform::RUBY
end
