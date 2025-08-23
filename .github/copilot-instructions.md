# Feedjira Ruby Library

Feedjira is a Ruby library designed to parse feeds (RSS, Atom, JSON feeds). It provides a unified interface for parsing different feed formats and extracting structured data from them.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

Bootstrap, build, and test the repository:

- `gem install bundler --user-install` -- installs bundler for user-specific installation
- `export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"` -- add bundler to PATH
- `bundle config set --local path 'vendor/bundle'` -- configure local bundle installation
- `bundle install` -- takes 30-60 seconds to complete with dependencies installation. NEVER CANCEL. Set timeout to 120+ seconds.
- `bundle exec rake` -- runs both tests and rubocop, takes ~3 seconds. NEVER CANCEL. Set timeout to 60+ seconds.

Run tests specifically:
- `bundle exec rake spec` -- runs RSpec test suite, takes ~2 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
- `bundle exec rake rubocop` -- runs code style checks, takes ~3 seconds. NEVER CANCEL. Set timeout to 60+ seconds.

Generate documentation:
- `bundle exec yard doc` -- generates API documentation, takes ~2 seconds. NEVER CANCEL. Set timeout to 60+ seconds.

## Validation

Always manually validate any new code by running through complete scenarios after making changes:
- ALWAYS run the full test suite with `bundle exec rake` before submitting changes.
- ALWAYS test feed parsing functionality by creating a Ruby script that parses RSS, Atom, and JSON feeds.
- You can build and test the library successfully - it has excellent test coverage (98%+).
- Always run `bundle exec rake` (which includes `bundle exec rubocop`) before you are done or the CI (.github/workflows/ruby.yml) will fail.

## Working with Feed Parsing

Test feed parsing functionality:
```ruby
require './lib/feedjira'
require './spec/sample_feeds'
include SampleFeeds

# Parse RSS feed
rss_xml = sample_rss_feed
rss_feed = Feedjira.parse(rss_xml)
puts "RSS Title: #{rss_feed.title}"
puts "RSS Entries: #{rss_feed.entries.size}"

# Parse Atom feed  
atom_xml = sample_atom_feed
atom_feed = Feedjira.parse(atom_xml)
puts "Atom Title: #{atom_feed.title}"

# Parse JSON feed
json_content = sample_json_feed
json_feed = Feedjira.parse(json_content)
puts "JSON Title: #{json_feed.title}"
```

Launch interactive console for testing:
- `bundle exec irb -r ./lib/feedjira` -- starts IRB with Feedjira loaded
- `bundle exec pry -r ./lib/feedjira` -- starts Pry console with Feedjira loaded

## Project Structure

### Repository Root
```
README.md          # Project overview and usage examples
Gemfile           # Ruby dependencies
Rakefile          # Build tasks (spec, rubocop, yard)
feedjira.gemspec  # Gem specification
.rubocop.yml      # Code style configuration
.rspec            # RSpec configuration
```

### Source Code
- `lib/feedjira.rb` -- Main library file and module definition
- `lib/feedjira/` -- Core library modules and utilities
- `lib/feedjira/parser/` -- Feed parser implementations (RSS, Atom, JSON, etc.)
- `lib/feedjira/core_ext/` -- Ruby core extensions (String, Time, Date)

### Tests
- `spec/feedjira/` -- Main test files organized by module
- `spec/feedjira/parser/` -- Parser-specific tests
- `spec/sample_feeds/` -- XML and JSON sample feeds for testing
- `spec/spec_helper.rb` -- Test configuration and setup

### Key Classes and Modules
- `Feedjira` -- Main module with `.parse()` and `.parser_for_xml()` methods
- `Feedjira::Parser::RSS` -- RSS feed parser
- `Feedjira::Parser::Atom` -- Atom feed parser  
- `Feedjira::Parser::JSONFeed` -- JSON feed parser
- `Feedjira::Configuration` -- Global configuration options

## Common Tasks

The following are outputs from frequently run commands. Reference them instead of viewing, searching, or running bash commands to save time.

### Available Parsers
When you require the library, these parsers are available in order:
1. `Feedjira::Parser::ITunesRSS`
2. `Feedjira::Parser::RSSFeedBurner`
3. `Feedjira::Parser::GoogleDocsAtom`
4. `Feedjira::Parser::AtomYoutube`
5. `Feedjira::Parser::AtomFeedBurner`
6. `Feedjira::Parser::AtomGoogleAlerts`
7. `Feedjira::Parser::Atom`
8. `Feedjira::Parser::RSS`
9. `Feedjira::Parser::JSONFeed`

### Current Version
Feedjira version: 3.2.6

### Dependencies
The project requires Ruby >= 2.7 and depends on:
- `sax-machine` for XML parsing
- `loofah` for HTML sanitization
- `logger` for logging

### Development Dependencies
- `rspec` for testing
- `rubocop` for code style
- `yard` for documentation
- `pry` for debugging
- `faraday` for HTTP requests in tests
- `ox` and `oga` for alternative XML parsing

## Validation Scenarios

### Basic Feed Parsing Validation
After making changes, always test:
1. Parse an RSS feed and verify title, URL, and entries are extracted
2. Parse an Atom feed and verify metadata is correctly parsed
3. Parse a JSON feed and verify structure is maintained
4. Test parser selection works automatically for different feed types

### Sample Test Script
Create this validation script in `/tmp/test_feedjira.rb`:
```ruby
require './lib/feedjira'
require './spec/sample_feeds'
include SampleFeeds

# Test all major feed types
feeds = [
  { type: 'RSS', content: sample_rss_feed },
  { type: 'Atom', content: sample_atom_feed },
  { type: 'JSON', content: sample_json_feed }
]

feeds.each do |feed_info|
  feed = Feedjira.parse(feed_info[:content])
  puts "✓ #{feed_info[:type]} feed parsed successfully"
  puts "  Title: #{feed.title}"
  puts "  Entries: #{feed.entries.size}"
end

puts "✓ All feed types validated successfully"
```

Run with: `bundle exec ruby /tmp/test_feedjira.rb`

## Troubleshooting

### Common Issues
- If bundler is not found: Install with `gem install bundler --user-install` and update PATH
- If bundle install fails with permissions: Use `bundle config set --local path 'vendor/bundle'`
- If tests fail: Check that all dependencies are installed with `bundle install`
- If rubocop fails: Run `bundle exec rubocop -a` to auto-correct style issues

### Environment Requirements
- Ruby 2.7+ (tested on 2.7, 3.0, 3.1, 3.2, 3.3)
- Bundler gem manager
- Standard UNIX environment (Linux/macOS)

### CI Information
- GitHub Actions runs tests on multiple Ruby versions
- Tests also run with different XML handlers (nokogiri, ox, oga)
- All builds must pass both RSpec tests and RuboCop style checks