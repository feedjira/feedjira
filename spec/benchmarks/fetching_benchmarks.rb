require 'rubygems'
require File.dirname(__FILE__) + '/../../lib/feedzirra.rb'

require 'open-uri'

require 'benchmark'
include Benchmark

iterations = 10
urls = File.readlines(File.dirname(__FILE__) + "/../sample_feeds/successful_feed_urls.txt").slice(0, 20)
puts "benchmarks on #{urls.size} feeds"
puts "************************************"
benchmark do |t|
  t.report("feedzirra open uri") do
    iterations.times do
      urls.each do |url|
        Feedzirra::Feed.parse(open(url, "User-Agent" => "feedzirra http://github.com/pauldix/feedzirra/tree/master").read)
        $stdout.print '.'; $stdout.flush
      end
    end
  end

  t.report("feedzirra fetch and parse") do
    iterations.times do
      Feedzirra::Feed.fetch_and_parse(urls, :on_success => lambda { |url, feed| $stdout.print '.'; $stdout.flush })
    end
  end
end
