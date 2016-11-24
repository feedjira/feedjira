require File.expand_path(File.dirname(__FILE__) + '/../lib/feedjira')
require 'sample_feeds'
require 'vcr'

SAXMachine.handler = ENV['HANDLER'].to_sym if ENV['HANDLER']

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :faraday
end

RSpec.configure do |c|
  c.include SampleFeeds
end
