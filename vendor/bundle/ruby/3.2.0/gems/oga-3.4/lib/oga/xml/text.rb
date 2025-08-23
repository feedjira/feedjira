module Oga
  module XML
    # Class containing information about a single text node. Text nodes don't
    # have any children, attributes and the likes; just text.
    class Text < CharacterNode
      def initialize(*args)
        super

        @decoded = false
      end

      # @param [String] value
      def text=(value)
        @decoded = false
        @text    = value
      end

      # Returns the text as a String. Upon the first call any XML/HTML entities
      # are decoded.
      #
      # @return [String]
      def text
        if decode_entities?
          @text    = EntityDecoder.try_decode(@text, html?)
          @decoded = true
        end

        @text
      end

      # @return [TrueClass|FalseClass]
      def decode_entities?
        !@decoded && !inside_literal_html?
      end

      # @return [TrueClass|FalseClass]
      def inside_literal_html?
        node = parent

        node && html? && node.literal_html_name?
      end
    end # Text
  end # XML
end # Oga
