module Oga
  module HTML
    # SAX parser for HTML documents. See the documentation of
    # {Oga::XML::SaxParser} for more information.
    class SaxParser < XML::SaxParser
      # @see [Oga::XML::SaxParser#initialize]
      def initialize(handler, data, options = {})
        options = options.merge(:html => true)

        super(handler, data, options)
      end
    end # SaxParser
  end # HTML
end # Oga
