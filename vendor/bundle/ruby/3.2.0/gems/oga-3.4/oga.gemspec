require File.expand_path('../lib/oga/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'oga'
  s.version     = Oga::VERSION
  s.authors     = ['Yorick Peterse']
  s.email       = 'yorickpeterse@gmail.com'
  s.summary     = 'Oga is an XML/HTML parser written in Ruby.'
  s.homepage    = 'https://gitlab.com/yorickpeterse/oga/'
  s.description = s.summary
  s.license     = 'MPL-2.0'

  s.files = Dir.glob([
    'checkum/**/*',
    'doc/**/*',
    'lib/**/*.rb',
    'ext/**/*',
    'README.md',
    'LICENSE',
    'oga.gemspec',
    '.yardopts'
  ]).select { |path| File.file?(path) }

  if RUBY_PLATFORM == 'java'
    s.files << 'lib/liboga.jar'

    s.platform = 'java'
  else
    s.extensions = ['ext/c/extconf.rb']
  end

  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'ast'
  s.add_dependency 'ruby-ll', '~> 2.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', ['~> 3.0']
  s.add_development_dependency 'yard'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'kramdown'
  s.add_development_dependency 'benchmark-ips', ['~> 2.0']
  s.add_development_dependency 'rake-compiler'
end
