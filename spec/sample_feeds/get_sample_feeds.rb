# just a quick script to try to pull down some of the feeds from my subscriptions to look at and test against
require 'rubygems'
require 'ostruct'
require 'curl-multi'
require 'nokogiri'

subscriptions_xml = File.read("google-reader-subscriptions.xml")
elements = Nokogiri.XML(subscriptions_xml).search("outline[@xmlUrl]")
feeds = elements.map do |opml_entry|
  OpenStruct.new(
    :feed_url => opml_entry.attributes["xmlUrl"].to_s, 
    :title    => opml_entry.attributes["title"].to_s,
    :url      => opml_entry.attributes["htmlUrl"].to_s)
end

multi = Curl::Multi.new
feeds.each do |feed|
  on_failure = lambda do |ex|
    puts "Failed to retrieve #{feed.title} - #{feed.feed_url}"
    puts ex
    puts "********************************************************************************"
  end

  on_success = lambda do |body|
    puts "got #{feed.title} - #{feed.feed_url}"
    File.open("#{feed.title.gsub(/\W/, "")}.xml", "w") do |f|
      f.write(body)
    end
  end
  multi.get(feed.feed_url, on_success, on_failure)
end

multi.select([], []) while multi.size > 0