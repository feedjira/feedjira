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
      f = Feedzirra::Feed.parse(xml)
      title = f.title
      first_title = f.entries.first.title
      first_author = f.entries.first.author
      first_url = f.entries.first.url
    end
  end

  t.report("rfeedparser") do
    iterations.times do
      f = FeedParser.parse(xml)
      title = f.title
      first_title = f.entries.first.title
      first_author = f.entries.first.author
      first_url = f.entries.first.url
    end
  end

  t.report("feed-normalizer") do
    iterations.times do
      # have to use the :force option to make feed-normalizer parse an atom feed
      f = FeedNormalizer::FeedNormalizer.parse(xml, :force_parser => FeedNormalizer::SimpleRssParser)
      # title = f.title
      # first_title = f.entries.first.title
      # first_author = f.entries.first.author
      # first_url = f.entries.first.url
      # puts title
      # puts first_title
      # puts first_author
      # puts first_url
    end
  end
end
