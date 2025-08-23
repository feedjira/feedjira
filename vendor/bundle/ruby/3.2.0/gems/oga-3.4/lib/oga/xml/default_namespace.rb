module Oga
  module XML
    # The default XML namespace.
    #
    # @return [Oga::XML::Namespace]
    DEFAULT_NAMESPACE = Namespace.new(
      :name => 'xmlns',
      :uri  => 'http://www.w3.org/XML/1998/namespace'
    ).freeze
  end # XML
end # Oga
