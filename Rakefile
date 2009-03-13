require "spec"
require "spec/rake/spectask"
require 'lib/feedzirra.rb'

# Grab recently touched specs
def recent_specs(touched_since)
  recent_specs = FileList['app/**/*'].map do |path|

    if File.mtime(path) > touched_since
      spec = File.join('spec', File.dirname(path).split("/")[1..-1].join('/'),
        "#{File.basename(path, ".*")}_spec.rb")
      spec if File.exists?(spec)
    end
  end.compact

  recent_specs += FileList['spec/**/*_spec.rb'].select do |path|
    File.mtime(path) > touched_since
  end
  recent_specs.uniq
end


# Tasks

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

desc 'Run recent specs'
Spec::Rake::SpecTask.new("spec:recent") do |t|
  t.spec_opts = ["--format","specdoc","--color"]
  t.spec_files = recent_specs(Time.now - 600) # 10 min.
end
