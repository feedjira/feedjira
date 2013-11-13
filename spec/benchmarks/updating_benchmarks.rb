require 'rubygems'
require File.dirname(__FILE__) + '/../../lib/feedzirra.rb'

require 'benchmark'
include Benchmark

urls = File.readlines(File.dirname(__FILE__) + "/../sample_feeds/successful_feed_urls.txt")
puts "benchmarks on #{urls.size} feeds"
puts "************************************"
benchmark do |t|
  feeds = {}
  t.report("feedzirra fetch and parse") do
    feeds = Feedzirra::Feed.fetch_and_parse(urls,
      :on_success => lambda { |url, feed| $stdout.print '.'; $stdout.flush },
      :on_failure => lambda {|url, response_code, header, body| puts "#{response_code} ERROR on #{url}"})
  end

  # curb caches the dns lookups for 60 seconds. to make things fair we have to wait for the cache to expire
  puts "sleeping to wait for dns cache to clear"
  65.times {$stdout.print('.'); sleep(1)}
  puts "done"

  updated_feeds = []
  t.report("feedzirra update") do
    updated_feeds = Feedzirra::Feed.update(feeds.values.reject {|f| f.class == Fixnum},
      :on_success => lambda {|feed| $stdout.print '.'; $stdout.flush},
      :on_failure => lambda {|feed, response_code, header, body| puts "#{response_code} ERROR on #{feed.feed_url}"})
  end

  updated_feeds.each do |feed|
    puts feed.feed_url if feed.updated?
  end
end
