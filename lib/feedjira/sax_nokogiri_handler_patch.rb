# frozen_string_literal: true

require "sax-machine/handlers/sax_nokogiri_handler"

module Feedjira
  # sax-machine's Nokogiri handler turns on entity replacement, which makes
  # libxml2 load external entities declared in a feed's DOCTYPE (XXE). This
  # parses with Nokogiri's default instead, which still decodes predefined
  # entities, character references, and internal entities in text.
  module SAXNokogiriHandlerPatch
    # Parse without entity replacement so external entities are never loaded.
    def sax_parse(xml_input)
      ::Nokogiri::XML::SAX::Parser.new(self).parse(xml_input)
    end

    # Without entity replacement, libxml2 returns "&" in attribute values as
    # "&#38;", so we turn it back into "&".
    def start_element(name, attrs = [])
      super(name, attrs.map { |key, value| [key, value.gsub("&#38;", "&")] })
    end
  end
end

::SAXMachine::SAXNokogiriHandler.prepend(::Feedjira::SAXNokogiriHandlerPatch)
