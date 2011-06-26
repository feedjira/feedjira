require 'bundler'
Bundler.setup

require 'rake'
require 'rdoc/task'
require 'rspec'
require 'rspec/core/rake_task'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'feedzirra/version'

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

RSpec::Core::RakeTask.new do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run recent specs'
RSpec::Core::RakeTask.new("spec:recent") do |t|
  t.pattern = recent_specs(Time.now - 600) # 10 min.
end

RSpec::Core::RakeTask.new('spec:rcov') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/usr/lib/ruby,/usr/local,/var/lib,/Library', '--text-report']
end

RDoc::Task.new do |rd|
  rd.title    = 'Feedzirra'
  rd.rdoc_dir = 'rdoc'
  rd.rdoc_files.include('README.rdoc', 'lib/feedzirra.rb', 'lib/feedzirra/**/*.rb')
  rd.options = ["--quiet", "--opname", "index.html", "--line-numbers", "--inline-source", '--main', 'README.rdoc']
end

desc "Run all the tests"
task :default => :spec
