module Oga
  # Parses the given XML document.
  #
  # @example
  #  document = Oga.parse_xml('<root>Hello</root>')
  #
  # @see [Oga::XML::Lexer#initialize]
  #
  # @return [Oga::XML::Document]
  def self.parse_xml(xml, options = {})
    XML::Parser.new(xml, options).parse
  end

  # Parses the given HTML document.
  #
  # @example
  #  document = Oga.parse_html('<html>...</html>')
  #
  # @see [Oga::XML::Lexer#initialize]
  #
  # @return [Oga::XML::Document]
  def self.parse_html(html, options = {})
    HTML::Parser.new(html, options).parse
  end

  # Parses the given XML document using the SAX parser.
  #
  # @example
  #  handler = SomeSaxHandler.new
  #
  #  Oga.sax_parse_html(handler, '<root>Hello</root>')
  #
  # @see [Oga::XML::SaxParser#initialize]
  def self.sax_parse_xml(handler, xml, options = {})
    XML::SaxParser.new(handler, xml, options).parse
  end

  # Parses the given HTML document using the SAX parser.
  #
  # @example
  #  handler = SomeSaxHandler.new
  #
  #  Oga.sax_parse_html(handler, '<script>foo()</script>')
  #
  # @see [Oga::XML::SaxParser#initialize]
  def self.sax_parse_html(handler, html, options = {})
    HTML::SaxParser.new(handler, html, options).parse
  end
end # Oga
