require 'zlib'
require 'curb'
require 'sax-machine'
require 'loofah'
require 'uri'

require 'active_support/basic_object'
require 'active_support/core_ext/module'
require 'active_support/core_ext/kernel'
require 'active_support/core_ext/object'
require 'active_support/time'

require 'feedzirra/core_ext'

module Feedzirra
  autoload :FeedEntryUtilities, 'feedzirra/feed_entry_utilities'
  autoload :FeedUtilities,      'feedzirra/feed_utilities'
  autoload :Feed,               'feedzirra/feed'
  autoload :Parser,             'feedzirra/parser'
end
