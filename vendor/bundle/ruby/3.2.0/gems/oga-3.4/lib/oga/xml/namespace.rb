module Oga
  module XML
    # The Namespace class contains information about XML namespaces such as the
    # name and URI.
    class Namespace
      # @return [String]
      attr_accessor :name

      # @return [String]
      attr_accessor :uri

      # @param [Hash] options
      #
      # @option options [String] :name
      # @option options [String] :uri
      def initialize(options = {})
        @name = options[:name]
        @uri  = options[:uri]
      end

      # @return [String]
      def to_s
        name.to_s
      end

      # @return [String]
      def inspect
        "Namespace(name: #{name.inspect} uri: #{uri.inspect})"
      end

      # @param [Oga::XML::Namespace] other
      # @return [TrueClass|FalseClass]
      def ==(other)
        other.is_a?(self.class) && name == other.name && uri == other.uri
      end
    end # Namespace
  end # XML
end # Oga
