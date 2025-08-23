module Oga
  module XML
    # Class used for storing information about a single processing instruction.
    class ProcessingInstruction < CharacterNode
      # @return [String]
      attr_accessor :name

      # @param [Hash] options
      #
      # @option options [String] :name The name of the instruction.
      # @see [Oga::XML::CharacterNode#initialize]
      def initialize(options = {})
        super

        @name = options[:name]
      end

      # @return [String]
      def inspect
        "ProcessingInstruction(name: #{name.inspect} text: #{text.inspect})"
      end
    end # ProcessingInstruction
  end # XML
end # Oga
