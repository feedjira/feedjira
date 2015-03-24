require 'zlib'
require 'curb'
require 'sax-machine'
require 'loofah'

require 'feedjira/core_ext'
require 'feedjira/feed_entry_utilities'
require 'feedjira/feed_utilities'
require 'feedjira/feed'
require 'feedjira/parser'
require 'feedjira/parser/rss_entry'
require 'feedjira/parser/rss'
require 'feedjira/parser/atom_entry'
require 'feedjira/parser/atom'
require 'feedjira/preprocessor'
require 'feedjira/version'

require 'feedjira/parser/rss_feed_burner_entry'
require 'feedjira/parser/rss_feed_burner'
require 'feedjira/parser/itunes_rss_owner'
require 'feedjira/parser/itunes_rss_item'
require 'feedjira/parser/itunes_rss'
require 'feedjira/parser/atom_feed_burner_entry'
require 'feedjira/parser/atom_feed_burner'
require 'feedjira/parser/google_docs_atom_entry'
require 'feedjira/parser/google_docs_atom'
require 'feedjira/parser/rss_atypon_entry'
require 'feedjira/parser/rss_atypon'

module Feedjira
  class NoParserAvailable < StandardError; end
end
