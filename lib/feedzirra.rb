require "rubygems"

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'feedzirra/feed'

module SAXMachine
  VERSION = "0.0.1"
end