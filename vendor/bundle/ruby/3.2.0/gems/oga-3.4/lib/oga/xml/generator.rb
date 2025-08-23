module Oga
  module XML
    # Class for generating XML as a String based on an existing document.
    #
    # Basic usage:
    #
    #     element = Oga::XML::Element.new(name: 'root')
    #     element.inner_text = 'hello'
    #
    #     gen = Oga::XML::Generator.new(element)
    #
    #     gen.to_xml # => "<root>hello</root>"
    #
    # @private
    class Generator
      # @param [Oga::XML::Document|Oga::XML::Node] root The node to serialise.
      def initialize(root)
        @start = root

        if @start.respond_to?(:html?)
          @html_mode = @start.html?
        else
          @html_mode = false
        end
      end

      # Returns the XML for the current root node.
      #
      # @return [String]
      def to_xml
        current = @start
        output = ''

        while current
          children = false

          # Determine what callback to use for the current node. The order of
          # this statement is based on how likely it is for an arm to match.
          case current
          when Oga::XML::Element
            callback = :on_element
            children = true
          when Oga::XML::Text
            callback = :on_text
          when Oga::XML::Cdata
            callback = :on_cdata
          when Oga::XML::Comment
            callback = :on_comment
          when Oga::XML::Attribute
            callback = :on_attribute
          when Oga::XML::XmlDeclaration
            # This must come before ProcessingInstruction since XmlDeclaration
            # extends ProcessingInstruction.
            callback = :on_xml_declaration
          when Oga::XML::ProcessingInstruction
            callback = :on_processing_instruction
          when Oga::XML::Doctype
            callback = :on_doctype
          when Oga::XML::Document
            callback = :on_document
            children = true
          else
            raise TypeError, "Can't serialize #{current.class} to XML"
          end

          send(callback, current, output)

          if child_node = children && current.children[0]
            current = child_node
          elsif current == @start
            # When we have reached the root node we should not process
            # any of its siblings. If we did we'd include XML in the
            # output from elements no part of the root node.
            after_element(current, output) if current.is_a?(Element)

            break
          else
            # Make sure to always close the current element before
            # moving to any siblings.
            after_element(current, output) if current.is_a?(Element)

            until next_node = current.is_a?(Node) && current.next
              if current.is_a?(Node) && current != @start
                current = current.parent
              end

              after_element(current, output) if current.is_a?(Element)

              break if current == @start
            end

            current = next_node
          end
        end

        output
      end

      # @param [Oga::XML::Text] node
      # @param [String] output
      def on_text(node, output)
        if @html_mode && (parent = node.parent) && parent.literal_html_name?
          output << node.text
        else
          output << Entities.encode(node.text)
        end
      end

      # @param [Oga::XML::Cdata] node
      # @param [String] output
      def on_cdata(node, output)
        output << "<![CDATA[#{node.text}]]>"
      end

      # @param [Oga::XML::Comment] node
      # @param [String] output
      def on_comment(node, output)
        output << "<!--#{node.text}-->"
      end

      # @param [Oga::XML::ProcessingInstruction] node
      # @param [String] output
      def on_processing_instruction(node, output)
        output << "<?#{node.name}#{node.text}?>"
      end

      # @param [Oga::XML::Element] element
      # @param [String] output The content of the element.
      def on_element(element, output)
        name = element.expanded_name
        attrs = ''

        element.attributes.each do |attr|
          attrs << ' '
          on_attribute(attr, attrs)
        end

        if self_closing?(element)
          closing_tag = html_void_element?(element) ? '>' : ' />'

          output << "<#{name}#{attrs}#{closing_tag}"
        else
          output << "<#{name}#{attrs}>"
        end
      end

      # @param [Oga::XML::Element] element
      # @param [String] output
      def after_element(element, output)
        output << "</#{element.expanded_name}>" unless self_closing?(element)
      end

      # @param [Oga::XML::Attribute] attr
      # @param [String] output
      def on_attribute(attr, output)
        name = attr.expanded_name
        enc_value = attr.value ? Entities.encode_attribute(attr.value) : nil

        output << %Q(#{name}="#{enc_value}")
      end

      # @param [Oga::XML::Doctype] node
      # @param [String] output
      def on_doctype(node, output)
        output << "<!DOCTYPE #{node.name}"

        output << " #{node.type}" if node.type
        output << %Q{ "#{node.public_id}"} if node.public_id
        output << %Q{ "#{node.system_id}"} if node.system_id
        output << " [#{node.inline_rules}]" if node.inline_rules
        output << '>'
      end

      # @param [Oga::XML::Document] doc
      # @param [String] output
      def on_document(doc, output)
        if doc.xml_declaration
          on_xml_declaration(doc.xml_declaration, output)
          output << "\n"
        end

        if doc.doctype
          on_doctype(doc.doctype, output)
          output << "\n"
        end

        first_child = doc.children[0]

        # Prevent excessive newlines in case the next node is a newline text
        # node.
        if first_child.is_a?(Text) && first_child.text.start_with?("\r\n", "\n")
          output.chomp!
        end
      end

      # @param [Oga::XML::XmlDeclaration] node
      # @param [String] output
      def on_xml_declaration(node, output)
        output << '<?xml'

        [:version, :encoding, :standalone].each do |getter|
          value = node.send(getter)

          output << %Q{ #{getter}="#{value}"} if value
        end

        output << ' ?>'
      end

      # @param [Oga::XML::Element] element
      # @return [TrueClass|FalseClass]
      def self_closing?(element)
        if @html_mode && !HTML_VOID_ELEMENTS.allow?(element.name)
          false
        else
          element.children.empty?
        end
      end

      def html_void_element?(element)
        @html_mode && HTML_VOID_ELEMENTS.allow?(element.name)
      end
    end
  end
end
