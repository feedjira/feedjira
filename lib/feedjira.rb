require 'zlib'
require 'curb'
require 'sax-machine'
require 'loofah'

require 'feedjira/core_ext'
require 'feedjira/version'

module Feedjira
  autoload :FeedEntryUtilities, 'feedjira/feed_entry_utilities'
  autoload :FeedUtilities,      'feedjira/feed_utilities'
  autoload :Feed,               'feedjira/feed'
  autoload :Parser,             'feedjira/parser'

  class NoParserAvailable < StandardError; end
end
