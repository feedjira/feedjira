module Oga
  module HTML
    # Parser for processing HTML input. This parser is a small wrapper around
    # {Oga::XML::Parser} and takes care of setting the various options required
    # for parsing HTML documents.
    #
    # A basic example:
    #
    #     Oga::HTML::Parser.new('<meta charset="utf-8">').parse
    class Parser < XML::Parser
      # @param [String|IO] data
      # @param [Hash] options
      # @see [Oga::XML::Parser#initialize]
      def initialize(data, options = {})
        options = options.merge(:html => true)

        super(data, options)
      end
    end # Parser
  end # HTML
end # Oga
