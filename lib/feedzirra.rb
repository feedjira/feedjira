$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

gem 'activesupport'

require 'curb'
require 'sax-machine'
require 'dryopteris'
require 'active_support/basic_object'
require 'active_support/core_ext/object'
require 'active_support/core_ext/time'

require 'core_ext/date'

require 'feedzirra/feed_utilities'
require 'feedzirra/feed_entry_utilities'
require 'feedzirra/feed'

require 'feedzirra/rss_entry'
require 'feedzirra/rdf_entry'
require 'feedzirra/atom_entry'
require 'feedzirra/atom_feed_burner_entry'

require 'feedzirra/rss'
require 'feedzirra/rdf'
require 'feedzirra/atom'
require 'feedzirra/atom_feed_burner'

module Feedzirra
  VERSION = "0.0.1"
end