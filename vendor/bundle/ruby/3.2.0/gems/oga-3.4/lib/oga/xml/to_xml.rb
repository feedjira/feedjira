module Oga
  module XML
    # Module that provides a `#to_xml` method that serialises the current node
    # back to XML.
    module ToXML
      # @return [String]
      def to_xml
        Generator.new(self).to_xml
      end

      alias_method :to_s, :to_xml
    end
  end
end
