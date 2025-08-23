require 'ast'
require 'set'
require 'stringio'
require 'thread'

require 'oga/version'
require 'oga/oga'
require 'oga/lru'
require 'oga/entity_decoder'
require 'oga/blacklist'
require 'oga/whitelist'

# Load these first so that the native extensions don't have to define the
# Oga::XML namespace.
require 'oga/xml/lexer'
require 'oga/xml/parser'

require 'liboga'

#:nocov:
if RUBY_PLATFORM == 'java'
  org.liboga.Liboga.load(JRuby.runtime)
end
#:nocov:

require 'oga/xml/to_xml'
require 'oga/xml/html_void_elements'
require 'oga/xml/entities'
require 'oga/xml/querying'
require 'oga/xml/traversal'
require 'oga/xml/expanded_name'
require 'oga/xml/node'
require 'oga/xml/document'
require 'oga/xml/character_node'
require 'oga/xml/text'
require 'oga/xml/comment'
require 'oga/xml/cdata'
require 'oga/xml/processing_instruction'
require 'oga/xml/xml_declaration'
require 'oga/xml/doctype'
require 'oga/xml/namespace'
require 'oga/xml/default_namespace'
require 'oga/xml/attribute'
require 'oga/xml/element'
require 'oga/xml/node_set'
require 'oga/xml/generator'

require 'oga/xml/sax_parser'
require 'oga/xml/pull_parser'

require 'oga/html/parser'
require 'oga/html/sax_parser'
require 'oga/html/entities'

require 'oga/ruby/node'
require 'oga/ruby/generator'

require 'oga/xpath/lexer'
require 'oga/xpath/parser'
require 'oga/xpath/context'
require 'oga/xpath/compiler'
require 'oga/xpath/conversion'

require 'oga/css/lexer'
require 'oga/css/parser'
