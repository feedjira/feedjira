# Feedzirra [![Build Status](https://secure.travis-ci.org/pauldix/feedzirra.png)](http://travis-ci.org/pauldix/feedzirra)

I'd like feedback on the api and any bugs encountered on feeds in the wild. I've set up a [google group here](http://groups.google.com/group/feedzirra).

## Description

Feedzirra is a feed library that is designed to get and update many feeds as quickly as possible. This includes using libcurl-multi through the [curb](https://github.com/taf2/curb) gem for faster http gets, and libxml through [nokogiri](https://github.com/tenderlove/nokogiri) and [sax-machine](https://github.com/pauldix/sax-machine) for faster parsing.

Once you have fetched feeds using Feedzirra, they can be updated using the feed objects. Feedzirra automatically inserts etag and last-modified information from the http response headers to lower bandwidth usage, eliminate unnecessary parsing, and make things speedier in general.

Another feature present in Feedzirra is the ability to create callback functions that get called "on success" and "on failure" when getting a feed. This makes it easy to do things like log errors or update data stores.

The fetching and parsing logic have been decoupled so that either of them can be used in isolation if you'd prefer not to use everything that Feedzirra offers. However, the code examples below use helper methods in the Feed class that put everything together to make things as simple as possible.

The final feature of Feedzirra is the ability to define custom parsing classes. In truth, Feedzirra could be used to parse much more than feeds. Microformats, page scraping, and almost anything else are fair game.

## Speedup date parsing

In MRI the date parsing code is written in ruby and is optimized for readability over speed, to speed up this part you can install the [home_run](https://github.com/jeremyevans/home_run) gem to replace it with an optimized C version.

## Usage

[A gist of the following code](http://gist.github.com/57285)

```ruby
  require 'feedzirra'

  # fetching a single feed
  feed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/PaulDixExplainsNothing")

  # feed and entries accessors
  feed.title          # => "Paul Dix Explains Nothing"
  feed.url            # => "http://www.pauldix.net"
  feed.feed_url       # => "http://feeds.feedburner.com/PaulDixExplainsNothing"
  feed.etag           # => "GunxqnEP4NeYhrqq9TyVKTuDnh0"
  feed.last_modified  # => Sat Jan 31 17:58:16 -0500 2009 # it's a Time object

  entry = feed.entries.first
  entry.title      # => "Ruby Http Client Library Performance"
  entry.url        # => "http://www.pauldix.net/2009/01/ruby-http-client-library-performance.html"
  entry.author     # => "Paul Dix"
  entry.summary    # => "..."
  entry.content    # => "..."
  entry.published  # => Thu Jan 29 17:00:19 UTC 2009 # it's a Time object
  entry.categories # => ["...", "..."]

  # sanitizing an entry's content
  entry.title.sanitize   # => returns the title with harmful stuff escaped
  entry.author.sanitize  # => returns the author with harmful stuff escaped
  entry.content.sanitize # => returns the content with harmful stuff escaped
  entry.content.sanitize! # => returns content with harmful stuff escaped and replaces original (also exists for author and title)
  entry.sanitize!         # => sanitizes the entry's title, author, and content in place (as in, it changes the value to clean versions)
  feed.sanitize_entries!  # => sanitizes all entries in place

  # updating a single feed
  updated_feed = Feedzirra::Feed.update(feed)

  # an updated feed has the following extra accessors
  updated_feed.updated?     # returns true if any of the feed attributes have been modified. will return false if only new entries
  updated_feed.new_entries  # a collection of the entry objects that are newer than the latest in the feed before update

  # fetching multiple feeds
  feed_urls = ["http://feeds.feedburner.com/PaulDixExplainsNothing", "http://feeds.feedburner.com/trottercashion"]
  feeds = Feedzirra::Feed.fetch_and_parse(feed_urls)

  # feeds is now a hash with the feed_urls as keys and the parsed feed objects as values. If an error was thrown
  # there will be a Fixnum of the http response code instead of a feed object

  # updating multiple feeds. it expects a collection of feed objects
  updated_feeds = Feedzirra::Feed.update(feeds.values)

  # defining custom behavior on failure or success. note that a return status of 304 (not updated) will call the on_success handler
  feed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/PaulDixExplainsNothing",
      :on_success => lambda [|url, feed| puts feed.title ],
      :on_failure => lambda [|url, response_code, response_header, response_body| puts response_body ])
  # if a collection was passed into fetch_and_parse, the handlers will be called for each one

  # the behavior for the handlers when using Feedzirra::Feed.update is slightly different. The feed passed into on_success will be
  # the updated feed with the standard updated accessors. on failure it will be the original feed object passed into update

  # fetching a feed via a proxy (optional)
  feed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/PaulDixExplainsNothing", [:proxy_url => '10.0.0.1', :proxy_port => 3084])

```
## Extending

### Adding a feed parsing class

```ruby
  # Adds a new feed parsing class, this class will be used first
  Feedzirra::Feed.add_feed_class MyFeedClass
```

### Adding attributes to all feeds types / all entries types

```ruby
  # Add the generator attribute to all feed types
  Feedzirra::Feed.add_common_feed_element('generator')
  Feedzirra::Feed.fetch_and_parse("href="http://www.pauldix.net/atom.xml").generator # => 'TypePad'

  # Add some GeoRss information
  Feedzirra::Feed.add_common_feed_entry_element('geo:lat', :as => :lat)
  Feedzirra::Feed.fetch_and_parse("http://www.earthpublisher.com/georss.php").entries.each do |e|
      p "lat: #[e.lat}, long: #{e.long]"
  end
```

### Adding attributes to only one class

If you want to add attributes for only on class you simply have to declare them in the class

```ruby
  # Add some GeoRss information
  require 'lib/feedzirra/parser/rss_entry'

  class Feedzirra::Parser::RSSEntry
      element 'geo:lat', :as => :lat
      element 'geo:long', :as => :long
  end

  # Fetch a feed containing GeoRss info and print them
  Feedzirra::Feed.fetch_and_parse("http://www.earthpublisher.com/georss.php").entries.each do |e|
      p "lat: #[e.lat}, long: #{e.long]"
  end
```
## Benchmarks

One of the goals of Feedzirra is speed. This includes not only parsing, but fetching multiple feeds as quickly as possible. I ran a benchmark getting 20 feeds 10 times using Feedzirra, rFeedParser, and FeedNormalizer. For more details the [benchmark code can be found in the project in spec/benchmarks/feedzirra_benchmarks.rb](https://github.com/pauldix/feedzirra/blob/7fb5634c5c16e9c6ec971767b462c6518cd55f5d/spec/benchmarks/feedzirra_benchmarks.rb)

    feedzirra          5.170000   1.290000   6.460000 ( 18.917796)
    rfeedparser      104.260000  12.220000 116.480000 (244.799063)
    feed-normalizer   66.250000   4.010000  70.260000 (191.589862)

The result of that benchmark is a bit sketchy because of the network variability. Running 10 times against the same 20 feeds was meant to smooth some of that out. However, there is also a [benchmark comparing parsing speed in spec/benchmarks/parsing_benchmark.rb](https://github.com/pauldix/feedzirra/blob/7fb5634c5c16e9c6ec971767b462c6518cd55f5d/spec/benchmarks/parsing_benchmark.rb) on an atom feed.

    feedzirra        0.500000   0.030000   0.530000 (  0.658744)
    rfeedparser      8.400000   1.110000   9.510000 ( 11.839827)
    feed-normalizer  5.980000   0.160000   6.140000 (  7.576140)

There's also a [benchmark that shows the results of using Feedzirra to perform updates on feeds](https://github.com/pauldix/feedzirra/blob/45d64319544c61a4c9eb9f7f825c73b9f9030cb3/spec/benchmarks/updating_benchmarks.rb) you've already pulled in. I tested against 179 feeds. The first is the initial pull and the second is an update 65 seconds later. I'm not sure how many of them support etag and last-modified, so performance may be better or worse depending on what feeds you're requesting.

    feedzirra fetch and parse  4.010000   0.710000   4.720000 ( 15.110101)
    feedzirra update           0.660000   0.280000   0.940000 (  5.152709)

## TODO

This thing needs to hammer on many different feeds in the wild. I'm sure there will be bugs. I want to find them and crush them. I didn't bother using the test suite for feedparser. i wanted to start fresh.

Here are some more specific TODOs.
* Make a feedzirra-rails gem to integrate feedzirra seamlessly with Rails and ActiveRecord.
* Add support for authenticated feeds.
* Create a super sweet DSL for defining new parsers.
* Test against Ruby 1.9.1 and fix any bugs.
* I'm not keeping track of modified on entries. Should I add this?
* Clean up the fetching code inside feed.rb so it doesn't suck so hard.
* Make the feed_spec actually mock stuff out so it doesn't hit the net.
* Readdress how feeds determine if they can parse a document. Maybe I should use namespaces instead?

## LICENSE

(The MIT License)
 
Copyright (c) 2009-2012:
 
- [Paul Dix](http://pauldix.net)
- [Julien Kirch](http://archiloque.net/)
- [Ezekiel Templin](http://zeke.templ.in/)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
 
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
