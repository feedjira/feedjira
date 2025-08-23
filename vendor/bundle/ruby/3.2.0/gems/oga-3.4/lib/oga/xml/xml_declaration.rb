module Oga
  module XML
    # Class containing information about an XML declaration tag.
    class XmlDeclaration < ProcessingInstruction
      # @return [String]
      attr_accessor :version

      # @return [String]
      attr_accessor :encoding

      # Whether or not the document is a standalone document.
      # @return [String]
      attr_accessor :standalone

      # @param [Hash] options
      #
      # @option options [String] :version
      # @option options [String] :encoding
      # @option options [String] :standalone
      def initialize(options = {})
        super

        @version    = options[:version] || '1.0'
        @encoding   = options[:encoding] || 'UTF-8'
        @standalone = options[:standalone]
        @name       = 'xml'
      end

      # @return [String]
      def inspect
        segments = []

        [:version, :encoding, :standalone].each do |attr|
          value = send(attr)

          if value and !value.empty?
            segments << "#{attr}: #{value.inspect}"
          end
        end

        "XmlDeclaration(#{segments.join(' ')})"
      end
    end # XmlDeclaration
  end # XML
end # Oga
