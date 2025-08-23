# frozen_string_literal: true

require "zlib"
require "sax-machine"
require "loofah"
require "logger"
require "json"

require_relative "feedjira/core_ext"
require_relative "feedjira/time_parser"
require_relative "feedjira/configuration"
require_relative "feedjira/feed_entry_utilities"
require_relative "feedjira/feed_utilities"
require_relative "feedjira/feed"
require_relative "feedjira/rss_entry_utilities"
require_relative "feedjira/atom_entry_utilities"
require_relative "feedjira/parser"
require_relative "feedjira/parser/globally_unique_identifier"
require_relative "feedjira/parser/rss_entry"
require_relative "feedjira/parser/rss_image"
require_relative "feedjira/parser/rss"
require_relative "feedjira/parser/atom_entry"
require_relative "feedjira/parser/atom"
require_relative "feedjira/preprocessor"
require_relative "feedjira/version"

require_relative "feedjira/parser/rss_feed_burner_entry"
require_relative "feedjira/parser/rss_feed_burner"
require_relative "feedjira/parser/podlove_chapter"
require_relative "feedjira/parser/itunes_rss_owner"
require_relative "feedjira/parser/itunes_rss_category"
require_relative "feedjira/parser/itunes_rss_item"
require_relative "feedjira/parser/itunes_rss"
require_relative "feedjira/parser/atom_feed_burner_entry"
require_relative "feedjira/parser/atom_feed_burner"
require_relative "feedjira/parser/atom_google_alerts_entry"
require_relative "feedjira/parser/atom_google_alerts"
require_relative "feedjira/parser/google_docs_atom_entry"
require_relative "feedjira/parser/google_docs_atom"
require_relative "feedjira/parser/atom_youtube_entry"
require_relative "feedjira/parser/atom_youtube"
require_relative "feedjira/parser/json_feed"
require_relative "feedjira/parser/json_feed_item"

# Feedjira
module Feedjira
  NoParserAvailable = Class.new(StandardError)

  extend Configuration

  # Parse XML with first compatible parser
  #
  # @example
  #   xml = HTTParty.get("http://example.com").body
  #   Feedjira.parse(xml)
  def parse(xml, parser: nil, &block)
    parser ||= parser_for_xml(xml)

    if parser.nil?
      raise NoParserAvailable, "No valid parser for XML."
    end

    parser.parse(xml, &block)
  end
  module_function :parse

  # Find compatible parser for given XML
  #
  # @example
  #   xml = HTTParty.get("http://example.com").body
  #   parser = Feedjira.parser_for_xml(xml)
  #   parser.parse(xml)
  def parser_for_xml(xml)
    Feedjira.parsers.detect { |klass| klass.able_to_parse?(xml) }
  end
  module_function :parser_for_xml
end
