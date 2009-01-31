require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'sax-machine'
require 'activesupport'
require 'curb'

require 'core_ext/object'

require 'feedzirra/feed_utilities'
require 'feedzirra/feed_entry_utilities'
require 'feedzirra/feed'
require 'feedzirra/atom_entry'
require 'feedzirra/atom_feed_burner_entry'
require 'feedzirra/rdf_entry'
require 'feedzirra/rss_entry'
require 'feedzirra/parser'

parsers = Dir[File.join(File.dirname(__FILE__), *%w[feedzirra parsers *])]
parsers.each { |lib| require lib }

# Feed parsers

module Feedzirra
  VERSION = "0.0.1"
end