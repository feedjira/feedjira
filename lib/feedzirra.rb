require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'feedzirra/feed'
require 'feedzirra/atom'
require 'feedzirra/atom_feed_burner'
require 'feedzirra/rdf'
require 'feedzirra/rss'

module SAXMachine
  VERSION = "0.0.1"
end