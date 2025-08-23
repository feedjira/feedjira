module Oga
  module XML
    # The PullParser class can be used to parse an XML document incrementally
    # instead of parsing it as a whole. This results in lower memory usage and
    # potentially faster parsing times. The downside is that pull parsers are
    # typically more difficult to use compared to DOM parsers.
    #
    # Basic parsing using this class works as following:
    #
    #     parser = Oga::XML::PullParser.new('... xml here ...')
    #
    #     parser.parse do |node|
    #       if node.is_a?(Oga::XML::PullParser)
    #
    #       end
    #     end
    #
    # This parses yields proper XML instances such as {Oga::XML::Element}.
    # Doctypes and XML declarations are ignored by this parser.
    class PullParser < Parser
      # @return [Oga::XML::Node]
      attr_reader :node

      # Array containing the names of the currently nested elements.
      # @return [Array]
      attr_reader :nesting

      # @return [Array]
      DISABLED_CALLBACKS = [
        :on_document,
        :on_doctype,
        :on_xml_decl,
        :on_element_children
      ]

      # @return [Array]
      BLOCK_CALLBACKS = [
        :on_cdata,
        :on_comment,
        :on_text,
        :on_proc_ins
      ]

      # Returns the shorthands that can be used for various node classes.
      #
      # @return [Hash]
      NODE_SHORTHANDS = {
        :text            => XML::Text,
        :node            => XML::Node,
        :cdata           => XML::Cdata,
        :element         => XML::Element,
        :doctype         => XML::Doctype,
        :comment         => XML::Comment,
        :xml_declaration => XML::XmlDeclaration
      }

      def initialize(*args)
        super
        @nesting = []
      end

      # Parses the input and yields every node to the supplied block.
      #
      # @yieldparam [Oga::XML::Node]
      def parse(&block)
        @block = block

        super

        return
      end

      # Calls the supplied block if the current node type and optionally the
      # nesting match. This method allows you to write this:
      #
      #     parser.parse do |node|
      #       parser.on(:text, %w{people person name}) do
      #         puts node.text
      #       end
      #     end
      #
      # Instead of this:
      #
      #     parser.parse do |node|
      #       if node.is_a?(Oga::XML::Text) and parser.nesting == %w{people person name}
      #         puts node.text
      #       end
      #     end
      #
      # When calling this method you can specify the following node types:
      #
      # * `:cdata`
      # * `:comment`
      # * `:element`
      # * `:text`
      #
      # @example
      #  parser.on(:element, %w{people person name}) do
      #
      #  end
      #
      # @param [Symbol] type The type of node to act upon. This is a symbol as
      #  returned by {Oga::XML::Node#node_type}.
      #
      # @param [Array] nesting The element name nesting to act upon.
      def on(type, nesting = [])
        if node.is_a?(NODE_SHORTHANDS[type])
          if nesting.empty? or nesting == self.nesting
            yield
          end
        end
      end

      # eval is a heck of a lot faster than define_method on both Rubinius and
      # JRuby.
      DISABLED_CALLBACKS.each do |method|
        eval <<-EOF, nil, __FILE__, __LINE__ + 1
        def #{method}(*args)
          return
        end
        EOF
      end

      BLOCK_CALLBACKS.each do |method|
        eval <<-EOF, nil, __FILE__, __LINE__ + 1
        def #{method}(*args)
          @node = super
          @block.call(@node)
          return
        end
        EOF
      end

      # @see Oga::XML::Parser#on_element
      def on_element(*args)
        @node = super

        nesting << @node.name

        @block.call(@node)

        return
      end

      # @see Oga::XML::Parser#on_element_children
      def after_element(*args)
        nesting.pop

        return
      end
    end # PullParser
  end # XML
end # Oga
