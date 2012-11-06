require 'zlib'
require 'curb'
require 'sax-machine'
require 'loofah'
require 'uri'

<<<<<<< HEAD
require 'active_support/basic_object'
require 'active_support/deprecation'
require 'active_support/core_ext/module'
require 'active_support/core_ext/object'
require 'active_support/time'

=======
>>>>>>> 9681b630e23ec604caac5411eddbd2dc71d70806
require 'feedzirra/core_ext'
require 'feedzirra/version'

module Feedzirra
  autoload :FeedEntryUtilities, 'feedzirra/feed_entry_utilities'
  autoload :FeedUtilities,      'feedzirra/feed_utilities'
  autoload :Feed,               'feedzirra/feed'
  autoload :Parser,             'feedzirra/parser'
  
  class NoParserAvailable < StandardError; end
end
