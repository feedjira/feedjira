require 'benchmark'
require 'feedzirra'
require 'simple-rss'
require 'feed-normalizer'
require 'feed_me'

iterations = 10
urls = File.readlines(File.dirname(__FILE__) + '/feed_list.txt')
files = Dir.glob(File.dirname(__FILE__) + '/feed_xml/*.xml')
xmls = files.map { |file| File.open(file).read }

# suppress warnings
$VERBOSE = nil

puts 'Parsing benchmarks'

Benchmark.bm(15) do |b|
  b.report('feedzirra') do
    iterations.times do
      xmls.each { |xml| Feedzirra::Feed.parse xml }
    end
  end

  b.report('simple-rss') do
    iterations.times do
      xmls.each { |xml| SimpleRSS.parse xml }
    end
  end

  b.report('feed-normalizer') do
    iterations.times do
      xmls.each { |xml| FeedNormalizer::FeedNormalizer.parse xml }
    end
  end

  # incompatible with `ruby-feedparser`, same constant used
  require 'feed_parser'
  b.report('feed_parser') do
    iterations.times do
      xmls.each { |xml| FeedParser.new(feed_xml: xml).parse }
    end
  end

  b.report('feed_me') do
    iterations.times do
      xmls.each { |xml| FeedMe.parse xml }
    end
  end

  # incompatible with `feed_parser`, same constant used
  # require 'feedparser'
  # b.report('ruby-feedparser') do
  #   iterations.times do
  #     xmls.each { |xml| FeedParser::Feed::new xml }
  #   end
  # end
end

puts "\nFetch and parse benchmarks"

Benchmark.bm(15) do |b|
  b.report('feedzirra') do
    iterations.times { Feedzirra::Feed.fetch_and_parse urls }
  end

  # incompatible with `ruby-feedparser`, same constant used
  require 'feed_parser'
  b.report('feed_parser') do
    iterations.times do
      urls.each { |url| FeedParser.new(url: url).parse }
    end
  end
end
