require File.expand_path(File.dirname(__FILE__) + '/../lib/feedjira')
require 'sample_feeds'

SAXMachine.handler = ENV['HANDLER'].to_sym if ENV['HANDLER']

RSpec.configure do |c|
  c.include SampleFeeds
end
