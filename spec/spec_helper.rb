require File.expand_path(File.dirname(__FILE__) + '/../lib/feedjira')
require 'sample_feeds'

if ENV['HANDLER'] == 'ox'
  SAXMachine.handler = :ox
end

RSpec.configure do |c|
  c.include SampleFeeds
end
