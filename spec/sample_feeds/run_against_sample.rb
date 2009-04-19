require 'rubygems'
require File.dirname(__FILE__) + "/../../lib/feedzirra.rb"

feed_urls = File.readlines(File.dirname(__FILE__) + "/top5kfeeds.dat").collect {|line| line.split.first}

success = lambda do |url, feed|
  puts "SUCCESS - #{feed.title} - #{url}"
end

failed_feeds = []
failure = lambda do |url, response_code, header, body|
  failed_feeds << url if response_code == 200
  puts "*********** FAILED with #{response_code} on #{url}"
end

Feedzirra::Feed.fetch_and_parse(feed_urls, :on_success => success, :on_failure => failure)

File.open("./failed_urls.txt", "w") do |f|
  f.write failed_feeds.join("\n")
end