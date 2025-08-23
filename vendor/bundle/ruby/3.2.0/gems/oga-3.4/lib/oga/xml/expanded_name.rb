module Oga
  module XML
    module ExpandedName
      # Returns the expanded name of the current Element or Attribute.
      #
      # @return [String]
      def expanded_name
        namespace_name ? "#{namespace_name}:#{name}" : name
      end
    end # ExpandedName
  end # XML
end # Oga
