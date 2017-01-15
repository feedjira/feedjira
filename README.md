# Feedjira

[![Build Status][travis-badge]][travis] [![Code Climate][code-climate-badge]][code-climate] [![Gitter][gitter-badge]][gitter]

[travis-badge]: https://travis-ci.org/feedjira/feedjira.svg?branch=master
[travis]: http://travis-ci.org/feedjira/feedjira
[code-climate-badge]: https://codeclimate.com/github/feedjira/feedjira/badges/gpa.svg
[code-climate]: https://codeclimate.com/github/feedjira/feedjira
[gitter-badge]: https://badges.gitter.im/feedjira/feedjira.svg
[gitter]: https://gitter.im/feedjira/feedjira?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

Feedjira (formerly Feedzirra) is a Ruby library designed to fetch and parse
feeds as quickly as possible.

## Getting Started

Feedjira is tested with Ruby version 1.9.3 and 2.x so like any Ruby gem, the
first step is to install the gem:

```
$ gem install feedjira
```

Or add it to your Gemfile:

```ruby
gem "feedjira"
```

## Fetching and Parsing

For many users, the `fetch_and_parse` method is what they use Feedjira for. This
method takes a url and returns a Parser object:

```ruby
url = "http://feedjira.com/blog/feed.xml"
feed = Feedjira::Feed.fetch_and_parse(url)
# => #<Feedjira::Parser::Atom...>
```

These feed objects have both the meta data for a feed and an `entries`
collection that contains all the entries that were found:

```ruby
feed.title
# => "Feedjira Blog"
feed.url
# => "http://feedjira.com/blog"
feed.entries # returns an array of Entry objects
# => [<Feedjira::Feed::Entry ...>, <Feedjira::Feed::Entry ...>, ...]
```

These entry objects contain the data parsed from the feed XML:

```ruby
entry = feed.entries.first
entry.title
# => "Announcing verison 1.0"
entry.url
# => "http://feedjira.com/blog/2014-02-12-announcing-version-10.html"
```

## Just Parsing

The parsing functionality of Feedjira has been exposed so that it can be used in
isolation:

```ruby
xml = Faraday.get(url).body
feed = Feedjira::Feed.parse xml
feed.entries.first.title
# => "Announcing verison 1.0"
```

## Adding a feed parsing class

When determining which parser to use for a given XML document, the following
list of parser classes is used:

* `Feedjira::Parser::RSSFeedBurner`
* `Feedjira::Parser::GoogleDocsAtom`
* `Feedjira::Parser::AtomFeedBurner`
* `Feedjira::Parser::Atom`
* `Feedjira::Parser::ITunesRSS`
* `Feedjira::Parser::RSS`

You can insert your own parser at the front of this stack by calling
`add_feed_class`, like this:

```ruby
Feedjira::Feed.add_feed_class(MyAwesomeParser)
```

Now when you `fetch_and_parse`, `MyAwesomeParser` will be the first one to get a
chance to parse the feed.

If you have the XML and just want to provide a parser class for one parse, you
can specify that using `parse_with`:

```ruby
Feedjira::Feed.parse_with(MyAwesomeParser, xml)
```

## Adding attributes to all feeds types / all entries types

```ruby
# Add the generator attribute to all feed types
Feedjira::Feed.add_common_feed_element("generator")
Feedjira::Feed.fetch_and_parse("http://www.pauldix.net/atom.xml").generator
# => "TypePad"
```

## Adding attributes to only one class

If you want to add attributes for only one class you simply have to declare them
in the class

```ruby
# Add some GeoRss information
class Feedjira::Parser::RSSEntry
  element "georss:elevation", as: :elevation
end

# Fetch a feed containing GeoRss info and print them
url = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_week.atom"
Feedjira::Feed.fetch_and_parse(url).entries.each do |entry|
  puts "Elevation: #{entry.elevation}"
end
```

## Configuration

#### Stripping whitespace from XML

Feedjira can be configured to strip all whitespace but defaults to lstrip only:

```ruby
Feedjira.configure do |config|
  config.strip_whitespace = true
end
```

#### Follow redirect limit

For fetching feeds, the follow redirect limit defaults to 3 but can be set:

```ruby
Feedjira.configure do |config|
  config.follow_redirect_limit = 5
end
```

#### Request timeout

The request timeout defaults to 30 but can be set:

```ruby
Feedjira.configure do |config|
  config.request_timeout = 45
end
```

#### User agent

The default user agent is "Feedjira #{Version}" but can be set:

```ruby
Feedjira.configure do |config|
  config.user_agent = "Awesome Feed Reader"
end
```

## Testing

Feedjira uses [faraday][] to perform requests, so testing Feedjira is really
about [stubbing out faraday requests][stub].

[faraday]: https://github.com/lostisland/faraday
[stub]: https://github.com/lostisland/faraday#using-faraday-for-testing

## Projects that use Feedjira

Feedjira is used in some awesome projects around the web - from RSS readers to
add-ons and everything in between. Here are some of them:

* [Feedbin][]: Feedbin bills itself as a fast, simple RSS reader that delivers a
  great reading experience. It's a paid RSS reader that integrates with mobile
  apps and it even has a fully featured API!

* [Stringer][]: Stringer is a self-hosted, anti-social RSS reader. It's an
  open-source project that's easy to deploy to any host, there's even a
  one-click button to deploy on Heroku.

* [BlogFeeder][]: BlogFeeder is a paid Shopify App that makes it easy for you to
  import any external blog into your Shopify store. It helps improve your
  store's SEO and keeps your blogs in sync, plus a lot more.

* [Feedbunch][]: Feedbunch is an open source feed reader built to fill the hole
  left by Google Reader. It aims to support all features of Google Reader and
  actually improve on others.

* [The Old Reader][old]: The Old Reader advertises as the ultimate social RSS
  reader. It's free to start and also has a paid premium version. There's an API
  and it integrates with many different mobile apps.

* [Solve for All][solve]: Solve for All combines search engine and feed parsing
  while protecting your privacy. It's even extendable by the community!

[Feedbin]: https://feedbin.com/
[Stringer]: https://github.com/swanson/stringer
[BlogFeeder]: https://apps.shopify.com/blogfeeder
[Feedbunch]: https://github.com/amatriain/feedbunch
[old]: http://theoldreader.com/
[solve]: https://solveforall.com/

Note: to get your project on this list, simply [send an email](mailto:feedjira@gmail.com)
with your project's details.
