# -*- encoding: utf-8 -*-
# stub: oga 3.4 ruby lib
# stub: ext/c/extconf.rb

Gem::Specification.new do |s|
  s.name = "oga".freeze
  s.version = "3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yorick Peterse".freeze]
  s.date = "2022-08-02"
  s.description = "Oga is an XML/HTML parser written in Ruby.".freeze
  s.email = "yorickpeterse@gmail.com".freeze
  s.extensions = ["ext/c/extconf.rb".freeze]
  s.files = ["ext/c/extconf.rb".freeze]
  s.homepage = "https://gitlab.com/yorickpeterse/oga/".freeze
  s.licenses = ["MPL-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Oga is an XML/HTML parser written in Ruby.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<ast>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<ruby-ll>.freeze, ["~> 2.1"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_development_dependency(%q<kramdown>.freeze, [">= 0"])
  s.add_development_dependency(%q<benchmark-ips>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<rake-compiler>.freeze, [">= 0"])
end
