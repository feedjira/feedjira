require 'rubygems'
require File.dirname(__FILE__) + "/../../lib/feedzirra.rb"

feed_urls = File.readlines(File.dirname(__FILE__) + "/top5kfeeds.dat").collect {|line| line.split.first}

success = lambda do |url, feed|
  puts "SUCCESS - #{feed.title} - #{url}"
end

failure = lambda do |url, response_code, header, body|
  puts "*********** FAILED with #{response_code} on #{url}"
end

Feedzirra::Feed.fetch_and_parse(feed_urls, :on_success => success, :on_failure => failure)
