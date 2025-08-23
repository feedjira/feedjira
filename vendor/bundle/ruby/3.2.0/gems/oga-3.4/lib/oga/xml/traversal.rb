module Oga
  module XML
    # Module that provides methods to traverse DOM trees.
    module Traversal
      # Traverses through the node and yields every child node to the supplied
      # block.
      #
      # The block's body can also determine whether or not to traverse child
      # nodes. Preventing a node's children from being traversed can be done by
      # using `throw :skip_children`
      #
      # This method uses a combination of breadth-first and depth-first
      # traversal to traverse the entire XML tree in document order. See
      # http://en.wikipedia.org/wiki/Breadth-first_search for more information.
      #
      # @example
      #  document.each_node do |node|
      #    p node.class
      #  end
      #
      # @example Skipping the children of a certain node
      #  document.each_node do |node|
      #    if node.is_a?(Oga::XML::Element) and node.name == 'book'
      #      throw :skip_children
      #    end
      #  end
      #
      # @yieldparam [Oga::XML::Node] The current node.
      def each_node
        return to_enum(:each_node) unless block_given?

        visit = children.to_a.reverse

        until visit.empty?
          current = visit.pop

          catch :skip_children do
            yield current

            current.children.to_a.reverse_each do |child|
              visit << child
            end
          end
        end
      end
    end # Traversal
  end # XML
end # Oga
