module Oga
  module XML
    # A generic XML node. Instances of this class can belong to a
    # {Oga::XML::NodeSet} and can be used to query surrounding and parent
    # nodes.
    class Node
      include Traversal
      include ToXML

      # @return [Oga::XML::NodeSet]
      attr_reader :node_set

      # @return [Oga::XML::Node]
      attr_accessor :previous

      # @return [Oga::XML::Node]
      attr_accessor :next

      # @param [Hash] options
      #
      # @option options [Oga::XML::NodeSet] :node_set The node set that this
      #  node belongs to.
      #
      # @option options [Oga::XML::NodeSet|Array] :children The child nodes of
      #  the current node.
      def initialize(options = {})
        self.node_set = options[:node_set]
        self.children = options[:children] if options[:children]
      end

      # @param [Oga::XML::NodeSet] set
      def node_set=(set)
        @node_set  = set
        @root_node = nil
        @html_p    = nil
        @previous  = nil
        @next      = nil
      end

      # Returns the child nodes of the current node.
      #
      # @return [Oga::XML::NodeSet]
      def children
        @children ||= NodeSet.new([], self)
      end

      # Sets the child nodes of the element.
      #
      # @param [Oga::XML::NodeSet|Array] nodes
      def children=(nodes)
        if nodes.is_a?(NodeSet)
          nodes.owner = self
          nodes.take_ownership_on_nodes
          @children = nodes
        else
          @children = NodeSet.new(nodes, self)
        end
      end

      # Returns the parent node of the current node. If there is no parent node
      # `nil` is returned instead.
      #
      # @return [Oga::XML::Node]
      def parent
        node_set ? node_set.owner : nil
      end

      # Returns the previous element node or nil if there is none.
      #
      # @return [Oga::XML::Element]
      def previous_element
        node = self

        while node = node.previous
          return node if node.is_a?(Element)
        end

        return
      end

      # Returns the next element node or nil if there is none.
      #
      # @return [Oga::XML::Element]
      def next_element
        node = self

        while node = node.next
          return node if node.is_a?(Element)
        end

        return
      end

      # Returns the root document/node of the current node. The node is
      # retrieved by traversing upwards in the DOM tree from the current node.
      #
      # @return [Oga::XML::Document|Oga::XML::Node]
      def root_node
        unless @root_node
          node = self

          loop do
            if !node.is_a?(Document) and node.node_set
              node = node.node_set.owner
            else
              break
            end
          end

          @root_node = node
        end

        @root_node
      end

      # Removes the current node from the owning node set.
      #
      # @return [Oga::XML::Node]
      def remove
        return node_set.delete(self) if node_set
      end

      # Replaces the current node with another.
      #
      # @example Replacing with an element
      #  element = Oga::XML::Element.new(:name => 'div')
      #  some_node.replace(element)
      #
      # @example Replacing with a String
      #  some_node.replace('this will replace the current node with a text node')
      #
      # @param [String|Oga::XML::Node] other
      def replace(other)
        if other.is_a?(String)
          other = Text.new(:text => other)
        end

        before(other)
        remove
      end

      # Inserts the given node before the current node.
      #
      # @param [Oga::XML::Node] other
      def before(other)
        index = node_set.index(self)

        node_set.insert(index, other)
      end

      # Inserts the given node after the current node.
      #
      # @param [Oga::XML::Node] other
      def after(other)
        index = node_set.index(self) + 1

        node_set.insert(index, other)
      end

      # @return [TrueClass|FalseClass]
      def html?
        if @html_p.nil?
          root = root_node

          @html_p = root.is_a?(Document) && root.html?
        end

        @html_p
      end

      # @return [TrueClass|FalseClass]
      def xml?
        !html?
      end

      # Yields all ancestor elements of the current node.
      #
      # @example
      #  some_element.each_ancestor do |node|
      #    # ...
      #  end
      #
      # @yieldparam [Oga::XML::Node]
      def each_ancestor
        return to_enum(:each_ancestor) unless block_given?

        node = parent

        while node.is_a?(XML::Element)
          yield node

          node = node.parent
        end
      end
    end # Element
  end # XML
end # Oga
