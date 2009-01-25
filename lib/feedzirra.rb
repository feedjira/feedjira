require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'feedzirra/feed'
require 'feedzirra/atom'
require 'feedzirra/atom_entry'
require 'feedzirra/atom_feed_burner'
require 'feedzirra/atom_feed_burner_entry'
require 'feedzirra/rdf'
require 'feedzirra/rss'
require 'feedzirra/feed_utilities'

module SAXMachine
  VERSION = "0.0.1"
end