require "rubygems"

$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'sax-machine'
require 'curb'
require 'activesupport'

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