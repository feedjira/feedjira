require File.expand_path(File.dirname(__FILE__) + '/../lib/feedjira')

require 'benchmark'

iterations = 10
urls = File.readlines(File.dirname(__FILE__) + '/feed_list.txt')
files = Dir.glob(File.dirname(__FILE__) + '/feed_xml/*.xml')
xmls = files.map { |file| File.open(file).read }
feeds = Feedjira::Feed.fetch_and_parse(urls).values

Benchmark.bm(15) do |b|
  b.report('parse') do
    iterations.times do
      xmls.each { |xml| Feedjira::Feed.parse xml }
    end
  end

  b.report('fetch_and_parse') do
    iterations.times { Feedjira::Feed.fetch_and_parse urls }
  end

  # curb caches the DNS lookups for 60 seconds, so to make things fair we have
  # to wait for the cache to expire
  65.times { sleep 1 }

  b.report('update') do
    iterations.times do
      feeds.each { |feed| Feedjira::Feed.update feed }
    end
  end
end
