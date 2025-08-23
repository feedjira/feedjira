module Oga
  module XML
    # Base class for nodes that represent a text-like value such as Text and
    # Comment nodes.
    class CharacterNode < Node
      # @return [String]
      attr_accessor :text

      # @param [Hash] options
      #
      # @option options [String] :text The text of the node.
      def initialize(options = {})
        super

        @text = options[:text]
      end

      # @return [String]
      def inspect
        "#{self.class.to_s.split('::').last}(#{text.inspect})"
      end
    end # CharacterNode
  end # XML
end # Oga
