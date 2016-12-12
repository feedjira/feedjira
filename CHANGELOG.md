# Feedjira Changelog

## 2.1.0

* Enhancements
  * AtomYoutube is now a supported parser [#337][] (@jfiorato)
  * Oga parsing is now supported [#331][] (@krasnoukhov)
  * DateTime Handler now supports localized dates [#313][] (@PascalTurbo)
  * RSS now supports language attribute [#344][] (@PascalTurbo)
  * ITunesRSS added support for:
    * `ttl` and `last_built` [#343][] (@sferik)
    * `itunes_category` and `itunes_category_paths` [#329][] (@knu)
    * `itunes_complete` [#328][] (@knu)
    * single quoted attributes [#326][] (@sferik)
    * Add image attribute [#349][] (@sferik)

## 2.0.0

* General
  * Replaced curb with faraday
  * Removed update functionality

## 1.6.0

* Enhancements
  * PuSH support for RSS [#256][]

[#256]: https://github.com/feedjira/feedjira/pull/256

## 1.5.0

* Enhancements
  * Handle XHTML content in summary and title [#250][]

[#250]: https://github.com/feedjira/feedjira/pull/250

## 1.4.0

* General
  * Test OX on Travis
  * Loosen dependency requirements

* Enhancements
  * Upgrade to SaxMachine 1 [#234][]
  * Upgrade to Rspec 3
  * Move lstrip before preprocess [#216][]

[#216]: https://github.com/feedjira/feedjira/pull/216
[#234]: https://github.com/feedjira/feedjira/pull/234

## 1.3.1

* Bug fixes
  * Don't duplicate content in preprocessed feeds [#236][] [#237][]

[#236]: https://github.com/feedjira/feedjira/issues/236
[#237]: https://github.com/feedjira/feedjira/pull/237

## 1.3.0

* General
  * Only build the master branch on Travis
  * Fix RBX on Travis

* Enhancements
  * Bump loofah to 2.0.0 [#223][]

* Bug fixes
  * Support preprocessing for AtomFeedBurner feeds [#222][]

[#222]: https://github.com/feedjira/feedjira/pull/222
[#223]: https://github.com/feedjira/feedjira/pull/223

## 1.2.0

* General
  * Benchmarks have been moved to [feedjira-benchmarks][bench]

* Enhancements
  * For Atom feeds, use self link for `feed_url` [#212][] [#213][]
  * For Atom feeds, don't use self link for `url` [#212][] [#213][]

* Bug fixes
  * Remove div that wraps xhtml content in Atom feeds [#214][]
  * Properly parse itunes:new-feed-url [#217][]

[bench]: https://github.com/feedjira/feedjira-benchmarks
[#212]: https://github.com/feedjira/feedjira/issues/212
[#213]: https://github.com/feedjira/feedjira/pull/213
[#214]: https://github.com/feedjira/feedjira/issues/214
[#217]: https://github.com/feedjira/feedjira/pull/217

## 1.1.0

* General
  * Add 2.1 to list of supported Rubies, drop 1.9.2
  * Remove Guard and Simplecov
  * Extract sample feeds into RSpec helper module
  * Random cleanup
  * Quiet down default rake task
  * Fix CHANGELOG links
  * Point README at new site

* Enhancements
  * Add language setting to curl options [#206][]

[#206]: https://github.com/feedjira/feedjira/pull/206

## 1.0.0

* Removed deprecated features

## 0.9.0

* Project renamed to Feedjira

## 0.7.1

* Bug fixes
  * Don't use entry id for updating when feed doesn't provide it [#205][]

[#205]: https://github.com/feedjira/feedjira/pull/205

## 0.7.0

* General
  * README update for callback arity [#202][]

* Enhancements
  * Add error info to `on_failure` callback [#194][]
  * On failure callbacks get curl and error as args
  * Bugfix for parsing dates that are ISO 8601 with milliseconds [#203][]

[#194]: https://github.com/feedjira/feedjira/pull/194
[#202]: https://github.com/feedjira/feedjira/pull/202
[#203]: https://github.com/feedjira/feedjira/pull/203

## 0.6.0

* General
  * Update expected parser classes in docs [#200][]
  * Fix Rubinius issue with Travis

* Enhancements
  * Added content to `itunes_rss_item` [#198][]
  * Allow user to pass a particular parser using `parse_with`
  * Strip leading whitespace from XML [#196][]
  * Parse out RSS version [#172][]
  * Add generic preprocessing hook for Parsers
  * Add preprocessing hook for Atom XHTML content [#58][] [#130][]

[#58]: https://github.com/feedjira/feedjira/pull/58
[#130]: https://github.com/feedjira/feedjira/issues/130
[#172]: https://github.com/feedjira/feedjira/issues/172
[#196]: https://github.com/feedjira/feedjira/pull/196
[#198]: https://github.com/feedjira/feedjira/pull/198
[#200]: https://github.com/feedjira/feedjira/pull/200

## 0.5.0

* General
  * Lots of README cleanup
  * Remove pending specs
  * Rewrite benchmarks and move them out of the spec folder
  * Upgrade to latest Rspec

* Enhancements
  * Allow spaces in rss tag when checking parse-ability [#127][]
  * Compare `entry_id` and `url` for finding new entries [#195][]
  * Add closed captioned and order tags for iTunesRSSItem [#160][]

[#127]: https://github.com/feedjira/feedjira/pull/127
[#160]: https://github.com/feedjira/feedjira/pull/160
[#195]: https://github.com/feedjira/feedjira/pull/195

## 0.4.0

* Enhancements
  * Raise when parser invokes its failure callback [#159][]
  * Add PubSubHubbub hub urls as feed element [#138][]
  * Add support for iTunes image in iTunes RSS item [#164][]

* Bug fixes
  * Use curb callbacks rather than response codes [#161][]

[#138]: https://github.com/feedjira/feedjira/pull/138
[#159]: https://github.com/feedjira/feedjira/issues/159
[#161]: https://github.com/feedjira/feedjira/pull/161
[#164]: https://github.com/feedjira/feedjira/pull/164

## 0.3.0

* General
  * Add CodeClimate badge [#192][]

* Enhancements
  * CURL SSL Version option [#156][]
  * Cookie support for Curb [#98][]

* Deprecations
  * For `ITunesRSSItem`, use `id` instead of `guid` [#169][]

[#98]: https://github.com/feedjira/feedjira/pull/98
[#156]: https://github.com/feedjira/feedjira/pull/156
[#169]: https://github.com/feedjira/feedjira/pull/169
[#192]: https://github.com/feedjira/feedjira/pull/192

## 0.2.2

* General
  * Switch to CHANGELOG
  * Set LICENSE in gemspec
  * Lots of whitespace cleaning
  * README updates

* Enhancements
  * Also use dc:identifier for `entry_id` [#182][]

* Bug fixes
  * Don't try to sanitize non-existent elements [#174][]
  * Fix Rspec deprecations [#188][]
  * Fix Travis [#191][]

[#174]: https://github.com/feedjira/feedjira/pull/174
[#182]: https://github.com/feedjira/feedjira/pull/182
[#188]: https://github.com/feedjira/feedjira/pull/188
[#191]: https://github.com/feedjira/feedjira/pull/191

## 0.2.1

* Use `Time.parse_safely` in `Feed.last_modified_from_header` [#129][]
* Added image to the RSS Entry Parser [#103][]
* Compatibility fixes for Ruby 2.0 [#136][]
* Remove gorillib dependency [#113][]

[#103]: https://github.com/feedjira/feedjira/pull/103
[#113]: https://github.com/feedjira/feedjira/pull/113
[#129]: https://github.com/feedjira/feedjira/pull/129
[#136]: https://github.com/feedjira/feedjira/pull/136

## 0.2.0.rc2

* Bump sax-machine to `v0.2.0.rc1`, fixes encoding issues [#76][]

[#76]: https://github.com/feedjira/feedjira/issues/76

## 0.2.0.rc1

* Remove ActiveSupport dependency
  * No longer tethered to any version of Rails!
* Update curb (v0.8.0) and rspec (v2.10.0)
* Revert [3008ceb][]
* Add Travis-CI integration
* General repository and gem maintenance

[3008ceb]: https://github.com/feedjira/feedjira/commit/3008ceb338df1f4c37a211d0aab8a6ad4f584dbc

## 0.1.3

* ?

## 0.1.2

* ?

## 0.1.1

* make FeedEntries enumerable (patch by Daniel Gregoire)

## 0.1.0

* lower builder requirement to make it rails-3 friendly
