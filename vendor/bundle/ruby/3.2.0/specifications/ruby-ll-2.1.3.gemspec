# -*- encoding: utf-8 -*-
# stub: ruby-ll 2.1.3 ruby lib
# stub: ext/c/extconf.rb

Gem::Specification.new do |s|
  s.name = "ruby-ll".freeze
  s.version = "2.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yorick Peterse".freeze]
  s.date = "2023-06-10"
  s.description = "An LL(1) parser generator for Ruby.".freeze
  s.email = "yorick@yorickpeterse.com".freeze
  s.executables = ["ruby-ll".freeze]
  s.extensions = ["ext/c/extconf.rb".freeze]
  s.files = ["bin/ruby-ll".freeze, "ext/c/extconf.rb".freeze]
  s.homepage = "https://github.com/yorickpeterse/ruby-ll".freeze
  s.licenses = ["MPL-2.0".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "An LL(1) parser generator for Ruby.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<ast>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<ansi>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_development_dependency(%q<kramdown>.freeze, [">= 0"])
  s.add_development_dependency(%q<benchmark-ips>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<rake-compiler>.freeze, [">= 0"])
end
