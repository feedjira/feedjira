require "spec"
require "spec/rake/spectask"
require 'lib/feedzirra.rb'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/usr/lib/ruby,/usr/local,/var/lib,/Library', '--text-report']
end

task :install do
  rm_rf "*.gem"
  puts `gem build feedzirra.gemspec`
  puts `sudo gem install feedzirra-#{Feedzirra::VERSION}.gem`
end