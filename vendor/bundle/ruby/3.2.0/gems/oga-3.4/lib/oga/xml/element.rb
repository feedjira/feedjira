module Oga
  module XML
    # Class that contains information about an XML element such as the name,
    # attributes and child nodes.
    class Element < Node
      include Querying
      include ExpandedName

      # @return [String]
      attr_reader :namespace_name

      # @return [String]
      attr_accessor :name

      # @return [Array<Oga::XML::Attribute>]
      attr_accessor :attributes

      # @return [Hash]
      attr_writer :namespaces

      # The attribute prefix/namespace used for registering element namespaces.
      #
      # @return [String]
      XMLNS_PREFIX = 'xmlns'.freeze

      # @param [Hash] options
      #
      # @option options [String] :name The name of the element.
      #
      # @option options [String] :namespace_name The name of the namespace.
      #
      # @option options [Array<Oga::XML::Attribute>] :attributes The attributes
      #  of the element as an Array.
      def initialize(options = {})
        super

        @name                 = options[:name]
        @namespace_name       = options[:namespace_name]
        @attributes           = options[:attributes] || []
        @namespaces           = options[:namespaces] || {}
        @available_namespaces = nil

        link_attributes
        register_namespaces_from_attributes
      end

      # @param [String] name
      def namespace_name=(name)
        @namespace_name = name
        @namespace      = nil
      end

      # Returns an attribute matching the given name (with or without the
      # namespace).
      #
      # @example
      #  # find an attribute that only has the name "foo"
      #  attribute('foo')
      #
      #  # find an attribute with namespace "foo" and name bar"
      #  attribute('foo:bar')
      #
      # @param [String|Symbol] name The name (with or without the namespace)
      #  of the attribute.
      #
      # @return [Oga::XML::Attribute]
      def attribute(name)
        name_str, ns = if html?
          [name.to_s, nil]
        else
          split_name(name)
        end

        attributes.each do |attr|
          return attr if attribute_matches?(attr, ns, name_str)
        end

        return
      end

      alias_method :attr, :attribute

      # Returns the value of the given attribute.
      #
      # @example
      #  element.get('class') # => "container"
      #
      # @see [#attribute]
      def get(name)
        found = attribute(name)

        found ? found.value : nil
      end

      alias_method :[], :get

      # Adds a new attribute to the element.
      #
      # @param [Oga::XML::Attribute] attribute
      def add_attribute(attribute)
        attribute.element = self

        attributes << attribute
      end

      # Sets the value of an attribute to the given value. If the attribute does
      # not exist it is created automatically.
      #
      # @param [String] name The name of the attribute, optionally including the
      #  namespace.
      #
      # @param [String] value The new value of the attribute.
      def set(name, value)
        found = attribute(name)

        if found
          found.value = value
        else
          name_str, ns = split_name(name)

          attr = Attribute.new(
            :name           => name_str,
            :namespace_name => ns,
            :value          => value
          )

          add_attribute(attr)
        end
      end

      alias_method :[]=, :set

      # Removes an attribute from the element.
      #
      # @param [String] name The name (optionally including namespace prefix)
      #  of the attribute to remove.
      #
      # @return [Oga::XML::Attribute]
      def unset(name)
        found = attribute(name)

        return attributes.delete(found) if found
      end

      # Returns the namespace of the element.
      #
      # @return [Oga::XML::Namespace]
      def namespace
        unless @namespace
          available  = available_namespaces
          @namespace = available[namespace_name] || available[XMLNS_PREFIX]
        end

        @namespace
      end

      # Returns the namespaces registered on this element, or an empty Hash in
      # case of an HTML element.
      #
      # @return [Hash]
      def namespaces
        html? ? {} : @namespaces
      end

      # Returns true if the current element resides in the default XML
      # namespace.
      #
      # @return [TrueClass|FalseClass]
      def default_namespace?
        namespace == DEFAULT_NAMESPACE || namespace.nil?
      end

      # Returns the text of all child nodes joined together.
      #
      # @return [String]
      def text
        children.text
      end

      # Returns the text of the current element only.
      #
      # @return [String]
      def inner_text
        text = ''

        text_nodes.each do |node|
          text << node.text
        end

        text
      end

      # Returns any {Oga::XML::Text} nodes that are a direct child of this
      # element.
      #
      # @return [Oga::XML::NodeSet]
      def text_nodes
        nodes = NodeSet.new

        children.each do |child|
          nodes << child if child.is_a?(Text)
        end

        nodes
      end

      # Sets the inner text of the current element to the given String.
      #
      # @param [String] text
      def inner_text=(text)
        text_node = XML::Text.new(:text => text)
        @children = NodeSet.new([text_node], self)
      end

      # @return [String]
      def inspect
        segments = []

        [:name, :namespace, :attributes, :children].each do |attr|
          value = send(attr)

          if !value or (value.respond_to?(:empty?) and value.empty?)
            next
          end

          segments << "#{attr}: #{value.inspect}"
        end

        "Element(#{segments.join(' ')})"
      end

      # Registers a new namespace for the current element and its child
      # elements.
      #
      # @param [String] name
      # @param [String] uri
      # @param [TrueClass|FalseClass] flush
      # @see [Oga::XML::Namespace#initialize]
      def register_namespace(name, uri, flush = true)
        if namespaces[name]
          raise ArgumentError, "The namespace #{name.inspect} already exists"
        end

        namespaces[name] = Namespace.new(:name => name, :uri => uri)

        flush_namespaces_cache if flush
      end

      # Returns a Hash containing all the namespaces available to the current
      # element.
      #
      # @return [Hash]
      def available_namespaces
        # HTML(5) completely ignores namespaces
        unless @available_namespaces
          if html?
            @available_namespaces = {}
          else
            merged = namespaces.dup
            node   = parent

            while node && node.respond_to?(:namespaces)
              node.namespaces.each do |prefix, ns|
                merged[prefix] = ns unless merged[prefix]
              end

              node = node.parent
            end

            @available_namespaces = merged
          end
        end

        @available_namespaces
      end

      # Returns `true` if the element is a self-closing element.
      #
      # @return [TrueClass|FalseClass]
      def self_closing?
        self_closing = children.empty?
        root         = root_node

        if root.is_a?(Document) and root.html? \
        and !HTML_VOID_ELEMENTS.allow?(name)
          self_closing = false
        end

        self_closing
      end

      # Flushes the namespaces cache of the current element and all its child
      # elements.
      def flush_namespaces_cache
        @available_namespaces = nil
        @namespace            = nil

        children.each do |child|
          child.flush_namespaces_cache if child.is_a?(Element)
        end
      end

      # Returns true if the current element name is the name of one of the
      # literal HTML elements.
      #
      # @return [TrueClass|FalseClass]
      def literal_html_name?
        Lexer::LITERAL_HTML_ELEMENTS.allow?(name)
      end

      private

      # Registers namespaces based on any "xmlns" attributes.
      def register_namespaces_from_attributes
        flush = false

        attributes.each do |attr|
          # We're using `namespace_name` opposed to `namespace.name` as "xmlns"
          # is not a registered namespace.
          if attr.name == XMLNS_PREFIX or attr.namespace_name == XMLNS_PREFIX
            flush = true

            # Ensures we only flush the cache once instead of flushing it on
            # every register_namespace call.
            register_namespace(attr.name, attr.value, false)
          end
        end

        flush_namespaces_cache if flush
      end

      # Links all attributes to the current element.
      def link_attributes
        attributes.each do |attr|
          attr.element = self
        end
      end

      # @param [String] name
      # @return [Array]
      def split_name(name)
        segments = name.to_s.split(':')

        [segments.pop, segments.pop]
      end

      # @param [Oga::XML::Attribute] attr
      # @param [String] ns
      # @param [String] name
      # @return [TrueClass|FalseClass]
      def attribute_matches?(attr, ns, name)
        name_matches = attr.name == name
        ns_matches   = false

        if ns
          ns_matches = attr.namespace.to_s == ns

        elsif name_matches and !attr.namespace
          ns_matches = true
        end

        name_matches && ns_matches
      end
    end # Element
  end # XML
end # Oga
