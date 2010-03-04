$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'zlib'
require 'curb'
require 'sax-machine'
require 'loofah'
require 'uri'

require 'active_support/version'
require 'active_support/basic_object'
require 'active_support/core_ext/object'
if ActiveSupport::VERSION::MAJOR >= 3
  require 'active_support/time'
else
  require 'active_support/core_ext/time'
end

require 'core_ext/date'
require 'core_ext/string'

require 'feedzirra/feed_utilities'
require 'feedzirra/feed_entry_utilities'
require 'feedzirra/feed'

require 'feedzirra/parser/rss_entry'
require 'feedzirra/parser/itunes_rss_owner'
require 'feedzirra/parser/itunes_rss_item'
require 'feedzirra/parser/atom_entry'
require 'feedzirra/parser/atom_feed_burner_entry'

require 'feedzirra/parser/rss'
require 'feedzirra/parser/itunes_rss'
require 'feedzirra/parser/atom'
require 'feedzirra/parser/atom_feed_burner'

module Feedzirra
  VERSION = "0.0.22"
end