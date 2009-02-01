require File.dirname(__FILE__) + '/../../lib/feedzirra.rb'
require 'rfeedparser'
require 'feed-normalizer'

require 'benchmark'
include Benchmark

iterations = 50
xml = File.read(File.dirname(__FILE__) + '/../sample_feeds/PaulDixExplainsNothing.xml')

benchmark do |t|    
  t.report("feedzirra") do
    iterations.times do
      Feedzirra::Feed.parse(xml)
    end
  end

  t.report("rfeedparser") do
    iterations.times do
      FeedParser.parse(xml)
    end
  end

  t.report("feed-normalizer") do
    iterations.times do
      # have to use the :force option to make feed-normalizer parse an atom feed
      FeedNormalizer::FeedNormalizer.parse(xml, :force_parser => FeedNormalizer::SimpleRssParser)
    end
  end
end
