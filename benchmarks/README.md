# Feedzirra Benchmarks

Speed is an important feature of Feedzirra and we use benchmarks to ensure we're
fast and we stay that way.

## Fetching Options

One way Feedzirra achieves its speed is by fetching feeds in parallel. This
benchmark compares ways to fetch feed urls:

```
                  user     system      total        real
Net::HTTP     0.310000   0.110000   0.420000 ( 10.111994)
Curl::Easy    0.140000   0.260000   0.400000 ( 14.692383)
Curl::Multi   0.100000   0.170000   0.270000 (  3.334533)
```

See the [fetching options code][fetching_options] for more details.

[fetching_options]: https://github.com/pauldix/feedzirra/blob/master/benchmarks/fetching_options.rb

## Basic Benchmarks

The basics to using Feedzirra are the `parse`, `fetch_and_parse` and `update`
methods, so this benchmark compares them:

```
                      user     system      total        real
parse             1.500000   0.010000   1.510000 (  1.498793)
fetch_and_parse   2.230000   0.310000   2.540000 ( 12.212616)
update            1.030000   0.270000   1.300000 ( 29.359274)
```

See the [basic benchmark code][basic] for more details.

[basic]: https://github.com/pauldix/feedzirra/blob/master/benchmarks/basic.rb

## Other Libraries

This benchmark compares various alternatives to Feedzirra. As of 11/29/13, these
are the top 10 gems in the [Atom & RSS Feed Parsing category][alternatives] on
Ruby Toolbox:

[alternatives]: https://www.ruby-toolbox.com/categories/feed_parsing

* Feedzirra
* Simple-rss
* Feed-normalizer
* Ratom
* Rfeedparser
* FeedParser
* Feed me
* Feedtosis
* Ruby-feedparser
* Opds

Only some of these are still under active deveopment and still others aren't a
good fit for this type of benchmark comparison. Notes on those that were left
out:

* Ratom => only supports Atom
* Rfeedparser => can't install, depends on hpricot v0.6
* Feedtosis => can't install, unresolved dependencies
* Opds => aimed at OPDS specifically

The remaining alternatives are benchmarked in two ways. The parsing benchmarks
just take raw XML and throw it at the library. Those that can also fetch, have a
second benchmark for that work.

Note: both FeedParser and Ruby-feedparser use the `FeedParser` namespace, so
their benchmarks can't be run at the same time.

```
Parsing benchmarks
                      user     system      total        real
feedzirra         1.560000   0.000000   1.560000 (  1.573555)
simple-rss       43.140000   0.150000  43.290000 ( 43.421603)
feed-normalizer  39.870000   0.130000  40.000000 ( 40.404832)
feed_parser       0.240000   0.000000   0.240000 (  0.249771)
feed_me           0.220000   0.010000   0.230000 (  0.229034)

Fetch and parse benchmarks
                      user     system      total        real
feedzirra         2.250000   0.320000   2.570000 ( 11.224833)
feed_parser       1.700000   0.290000   1.990000 ( 28.941270)
```

See the [other benchmark code][other_benchmark] for more details.

[other_benchmark]: https://github.com/pauldix/feedzirra/blob/master/benchmarks/other_libraries.rb
