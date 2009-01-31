require File.dirname(__FILE__) + '/../../lib/feedzirra.rb'
require 'rfeedparser'
require 'feed-normalizer'
require 'open-uri'

require 'benchmark'
include Benchmark

iterations = 10
urls = File.readlines(File.dirname(__FILE__) + "/../sample_feeds/successful_feed_urls.txt")
puts "benchmarks on #{urls.size} feeds"
puts "************************************"
benchmark do |t|    
  t.report("feedzirra") do
    iterations.times do
      Feedzirra::Feed.fetch_and_parse(urls, :on_success => lambda { |url, feed| $stdout.print '.'; $stdout.flush })
    end
  end

  t.report("rfeedparser") do
    iterations.times do
      urls.each do |url|
        feed = FeedParser.parse(url)
        $stdout.print '.'
        $stdout.flush
      end
    end
  end

  t.report("feed-normalizer") do
    urls.each do |url|
      feed = FeedNormalizer::FeedNormalizer.parse(open(url), :force_parser => FeedNormalizer::SimpleRssParser)
      $stdout.print '.'
      $stdout.flush
    end
  end
end
