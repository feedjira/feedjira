module Oga
  module XML
    # The SaxParser class provides the basic interface for writing custom SAX
    # parsers. All callback methods defined in {Oga::XML::Parser} are delegated
    # to a dedicated handler class.
    #
    # To write a custom handler for the SAX parser, create a class that
    # implements one (or many) of the following callback methods:
    #
    # * `on_document`
    # * `on_doctype`
    # * `on_cdata`
    # * `on_comment`
    # * `on_proc_ins`
    # * `on_xml_decl`
    # * `on_text`
    # * `on_element`
    # * `on_element_children`
    # * `on_attribute`
    # * `on_attributes`
    # * `after_element`
    #
    # For example:
    #
    #     class SaxHandler
    #       def on_element(namespace, name, attrs = {})
    #         puts name
    #       end
    #     end
    #
    # You can then use it as following:
    #
    #     handler = SaxHandler.new
    #     parser  = Oga::XML::SaxParser.new(handler, '<foo />')
    #
    #     parser.parse
    #
    # For information on the callback arguments see the documentation of the
    # corresponding methods in {Oga::XML::Parser}.
    #
    # ## Element Callbacks
    #
    # The SAX parser changes the behaviour of both `on_element` and
    # `after_element`. The latter in the regular parser only takes a
    # {Oga::XML::Element} instance. In the SAX parser it will instead take a
    # namespace name and the element name. This eases the process of figuring
    # out what element a callback is associated with.
    #
    # An example:
    #
    #     class SaxHandler
    #       def on_element(namespace, name, attrs = {})
    #         # ...
    #       end
    #
    #       def after_element(namespace, name)
    #         puts name # => "foo", "bar", etc
    #       end
    #     end
    #
    # ## Attributes
    #
    # Attributes returned by `on_attribute` are passed as an Hash as the 3rd
    # argument of the `on_element` callback. The keys of this Hash are the
    # attribute names (optionally prefixed by their namespace) and their values.
    # You can overwrite `on_attribute` to control individual attributes and
    # `on_attributes` to control the final set.
    class SaxParser < Parser
      # @param [Object] handler The SAX handler to delegate callbacks to.
      # @see [Oga::XML::Parser#initialize]
      def initialize(handler, *args)
        @handler = handler

        super(*args)
      end

      # Manually define `on_element` so we can ensure that `after_element`
      # always receives the namespace and name.
      #
      # @see [Oga::XML::Parser#on_element]
      # @return [Array]
      def on_element(namespace, name, attrs = [])
        run_callback(:on_element, namespace, name, attrs)

        [namespace, name]
      end

      # Manually define `after_element` so it can take a namespace and name.
      # This differs a bit from the regular `after_element` which only takes an
      # {Oga::XML::Element} instance.
      #
      # @param [Array] namespace_with_name
      def after_element(namespace_with_name)
        run_callback(:after_element, *namespace_with_name)

        return
      end

      # Manually define this method since for this one we _do_ want the
      # return value so it can be passed to `on_element`.
      #
      # @see [Oga::XML::Parser#on_attribute]
      def on_attribute(name, ns = nil, value = nil)
        if @handler.respond_to?(:on_attribute)
          return run_callback(:on_attribute, name, ns, value)
        end

        key = ns ? "#{ns}:#{name}" : name

        if value
          value = EntityDecoder.try_decode(value, @lexer.html?)
        end

        {key => value}
      end

      # Merges the attributes together into a Hash.
      #
      # @param [Array] attrs
      # @return [Hash]
      def on_attributes(attrs)
        if @handler.respond_to?(:on_attributes)
          return run_callback(:on_attributes, attrs)
        end

        merged = {}

        attrs.each do |pair|
          # Hash#merge requires an extra allocation, this doesn't.
          pair.each { |key, value| merged[key] = value }
        end

        merged
      end

      # @param [String] text
      def on_text(text)
        if @handler.respond_to?(:on_text)
          unless inside_literal_html?
            text = EntityDecoder.try_decode(text, @lexer.html?)
          end

          run_callback(:on_text, text)
        end

        return
      end

      # Delegate remaining callbacks to the handler object.
      existing_methods = instance_methods(false)

      instance_methods.grep(/^(on_|after_)/).each do |method|
        next if existing_methods.include?(method)

        eval <<-EOF, nil, __FILE__, __LINE__ + 1
        def #{method}(*args)
          run_callback(:#{method}, *args)

          return
        end
        EOF
      end

      private

      # @return [TrueClass|FalseClass]
      def inside_literal_html?
        @lexer.html_script? || @lexer.html_style?
      end

      # @param [Symbol] method
      # @param [Array] args
      def run_callback(method, *args)
        @handler.send(method, *args) if @handler.respond_to?(method)
      end
    end # SaxParser
  end # XML
end # Oga
