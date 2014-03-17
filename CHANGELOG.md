# Feedjira Changelog

## 1.0.0

* Removed deprecated features

## 0.9.0

* Project renamed to Feedjira

## 0.7.1

* Bugfix
  * Don't use entry id for updating when feed doesn't provide it [[#205][]]

[#205]: https://github.com/pauldix/feedzirra/pull/205

## 0.7.0

* General
  * README update for callback arity [[#202][]]

* Enhancements
  * Add error info to `on_failure` callback [[#194][]]
  * On failure callbacks get curl and error as args
  * Bugfix for parsing dates that are ISO 8601 with milliseconds [[#203][]]

[#194]: https://github.com/pauldix/feedzirra/pull/194
[#202]: https://github.com/pauldix/feedzirra/pull/202
[#203]: https://github.com/pauldix/feedzirra/pull/203

## 0.6.0

* General
  * Update expected parser classes in docs [[#200][]]
  * Fix Rubinius issue with Travis

* Enhancements
  * Added content to `itunes_rss_item` [[#198][]]
  * Allow user to pass a particular parser using `parse_with`
  * Strip leading whitespace from XML [[#196][]]
  * Parse out RSS version [[#172][]]
  * Add generic preprocessing hook for Parsers
  * Add preprocessing hook for Atom XHTML content [[#58][]] [[#130][]]

[#58]: https://github.com/pauldix/feedzirra/pull/58
[#130]: https://github.com/pauldix/feedzirra/issues/130
[#172]: https://github.com/pauldix/feedzirra/issues/172
[#196]: https://github.com/pauldix/feedzirra/pull/196
[#198]: https://github.com/pauldix/feedzirra/pull/198
[#200]: https://github.com/pauldix/feedzirra/pull/200

## 0.5.0

* General
  * Lots of README cleanup
  * Remove pending specs
  * Rewrite benchmarks and move them out of the spec folder
  * Upgrade to latest Rspec

* Enhancements
  * Allow spaces in rss tag when checking parse-ability [[#127][]]
  * Compare `entry_id` and `url` for finding new entries [[#195][]]
  * Add closed captioned and order tags for iTunesRSSItem [[#160][]]

[#127]: https://github.com/pauldix/feedzirra/pull/127
[#160]: https://github.com/pauldix/feedzirra/pull/160
[#195]: https://github.com/pauldix/feedzirra/pull/195

## 0.4.0

* Enhancements
  * Raise when parser invokes its failure callback [[#159][]]
  * Add PubSubHubbub hub urls as feed element [[#138][]]
  * Add support for iTunes image in iTunes RSS item [[#164][]]

* Bug fixes
  * Use curb callbacks rather than response codes [[#161][]]

[#138]: https://github.com/pauldix/feedzirra/pull/138
[#159]: https://github.com/pauldix/feedzirra/issues/159
[#161]: https://github.com/pauldix/feedzirra/pull/161
[#164]: https://github.com/pauldix/feedzirra/pull/164

## 0.3.0

* General
  * Add CodeClimate badge [[#192][]]

* Enhancements
  * CURL SSL Version option [[#156][]]
  * Cookie support for Curb [[#98][]]

* Deprecations
  * For `ITunesRSSItem`, use `id` instead of `guid` [[#169][]]

[#98]: https://github.com/pauldix/feedzirra/pull/98
[#156]: https://github.com/pauldix/feedzirra/pull/156
[#169]: https://github.com/pauldix/feedzirra/pull/169
[#192]: https://github.com/pauldix/feedzirra/pull/192

## 0.2.2

* General
  * Switch to CHANGELOG
  * Set LICENSE in gemspec
  * Lots of whitespace cleaning
  * README updates

* Enhancements
  * Also use dc:identifier for `entry_id` [[#182][]]

* Bug fixes
  * Don't try to sanitize non-existent elements [[#174][]]
  * Fix Rspec deprecations [[#188][]]
  * Fix Travis [[#191][]]

[#174]: https://github.com/pauldix/feedzirra/pull/174
[#182]: https://github.com/pauldix/feedzirra/pull/182
[#188]: https://github.com/pauldix/feedzirra/pull/188
[#191]: https://github.com/pauldix/feedzirra/pull/191

## 0.2.1

* Use `Time.parse_safely` in `Feed.last_modified_from_header` [[#129][]].
* Added image to the RSS Entry Parser [[#103][]].
* Compatibility fixes for Ruby 2.0 [[#136][]].
* Remove gorillib dependency [[#113][]].

[#103]: https://github.com/pauldix/feedzirra/pull/103
[#113]: https://github.com/pauldix/feedzirra/pull/113
[#129]: https://github.com/pauldix/feedzirra/pull/129
[#136]: https://github.com/pauldix/feedzirra/pull/136

## 0.2.0.rc2

* Bump sax-machine to `v0.2.0.rc1`, fixes encoding issues [[#76][]].

[#76]: https://github.com/pauldix/feedzirra/issues/76

## 0.2.0.rc1

* Remove ActiveSupport dependency
  * No longer tethered to any version of Rails!
* Update curb (v0.8.0) and rspec (v2.10.0)
* Revert [3008ceb][]
* Add Travis-CI integration
* General repository and gem maintenance

[3008ceb]: https://github.com/pauldix/feedzirra/commit/3008ceb338df1f4c37a211d0aab8a6ad4f584dbc

## 0.1.3

* ?

## 0.1.2

* ?

## 0.1.1

* make FeedEntries enumerable (patch by Daniel Gregoire)

## 0.1.0

* lower builder requirement to make it rails-3 friendly
