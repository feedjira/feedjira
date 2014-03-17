source 'https://rubygems.org/'

gemspec

group :development, :test do
  gem 'rake'
end

group :tools do
  gem 'simplecov', :require => false, :platforms => :mri_19
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl'
end
