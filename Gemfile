source 'https://rubygems.org/'

gemspec

group :development, :test do
  gem 'rake'
  gem 'guard-rspec'
  gem 'simplecov', :require => false, :platforms => :mri_19
  # TODO Remove this dependency after updating sax-machine dependency in gemspec
  gem 'sax-machine', github: "AutoUncle/sax-machine", ref: '95e5f8fedb5ed2d1b3b6bdf3e9ac8c3dc5750de7'
end
