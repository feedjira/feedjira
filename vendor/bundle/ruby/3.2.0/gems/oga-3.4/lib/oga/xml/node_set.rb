module Oga
  module XML
    # The NodeSet class contains a set of unique {Oga::XML::Node} instances that
    # can be queried and modified. Optionally NodeSet instances can take
    # ownership of a node (besides just containing it). This allows the nodes to
    # query their previous and next elements.
    #
    # There are two types of sets:
    #
    # 1. Regular node sets
    # 2. Owned node sets
    #
    # Both behave similar to Ruby's Array class. The difference between an
    # owned and regular node set is that an owned set modifies nodes that are
    # added or removed by certain operations. For example, when a node is added
    # to an owned set the `node_set` attribute of said node points to the set
    # it was just added to.
    #
    # Owned node sets are used when building a DOM tree with
    # {Oga::XML::Parser}. By taking ownership of nodes in a set Oga makes it
    # possible to use these sets as following:
    #
    #     document = Oga::XML::Document.new
    #     element  = Oga::XML::Element.new
    #
    #     document.children << element
    #
    #     element.node_set == document.children # => true
    #
    # If ownership was not handled then you'd have to manually set the
    # `element` variable's `node_set` attribute after pushing it into a set.
    class NodeSet
      include Enumerable

      # @return [Oga::XML::Node]
      attr_accessor :owner

      # @param [Array] nodes The nodes to add to the set.
      # @param [Oga::XML::NodeSet] owner The owner of the set.
      def initialize(nodes = [], owner = nil)
        @nodes    = nodes
        @owner    = owner
        @existing = {}

        take_ownership_on_nodes
      end

      # Yields the supplied block for every node.
      #
      # @yieldparam [Oga::XML::Node]
      def each
        return to_enum(:each) unless block_given?

        @nodes.each { |node| yield node }
      end

      # Returns the last node in the set.
      #
      # @return [Oga::XML::Node]
      def last
        @nodes[-1]
      end

      # Returns `true` if the set is empty.
      #
      # @return [TrueClass|FalseClass]
      def empty?
        @nodes.empty?
      end

      # Returns the amount of nodes in the set.
      #
      # @return [Fixnum]
      def length
        @nodes.length
      end

      alias_method :count, :length
      alias_method :size, :length

      # Returns the index of the given node.
      #
      # @param [Oga::XML::Node] node
      # @return [Fixnum]
      def index(node)
        @nodes.index(node)
      end

      # Pushes the node at the end of the set.
      #
      # @param [Oga::XML::Node] node
      def push(node)
        return if exists?(node)

        @nodes << node

        mark_existing(node)

        take_ownership(node, length - 1) if @owner
      end

      alias_method :<<, :push

      # Pushes the node at the start of the set.
      #
      # @param [Oga::XML::Node] node
      def unshift(node)
        return if exists?(node)

        @nodes.unshift(node)

        mark_existing(node)

        take_ownership(node, 0) if @owner
      end

      # Shifts a node from the start of the set.
      #
      # @return [Oga::XML::Node]
      def shift
        node = @nodes.shift

        if node
          unmark_existing(node)

          remove_ownership(node) if @owner
        end

        node
      end

      # Pops a node from the end of the set.
      #
      # @return [Oga::XML::Node]
      def pop
        node = @nodes.pop

        if node
          unmark_existing(node)

          remove_ownership(node) if @owner
        end

        node
      end

      # Inserts a node into the set at the given index.
      #
      # @param [Fixnum] index The index to insert the node at.
      # @param [Oga::XML::Node] node
      def insert(index, node)
        return if exists?(node)

        @nodes.insert(index, node)

        mark_existing(node)

        take_ownership(node, index) if @owner
      end

      # Returns the node for the given index.
      #
      # @param [Fixnum] index
      # @return [Oga::XML::Node]
      def [](index)
        @nodes[index]
      end

      # Converts the current set to an Array.
      #
      # @return [Array]
      def to_a
        @nodes
      end

      # Creates a new set based on the current and the specified set. The newly
      # created set does not inherit ownership rules of the current set.
      #
      # @param [Oga::XML::NodeSet] other
      # @return [Oga::XML::NodeSet]
      def +(other)
        self.class.new(to_a | other.to_a)
      end

      # Returns `true` if the current node set and the one given in `other` are
      # equal to each other.
      #
      # @param [Oga::XML::NodeSet] other
      def ==(other)
        other.is_a?(NodeSet) && other.equal_nodes?(@nodes)
      end

      # Returns `true` if the nodes given in `nodes` are equal to those
      # specified in the current `@nodes` variable. This method allows two
      # NodeSet instances to compare each other without the need of exposing
      # `@nodes` to the public.
      #
      # @param [Array<Oga::XML::Node>] nodes
      def equal_nodes?(nodes)
        @nodes == nodes
      end

      # Adds the nodes of the given node set to the current node set.
      #
      # @param [Oga::XML::NodeSet] other
      def concat(other)
        other.each { |node| push(node) }
      end

      # Removes the current nodes from their owning set. The nodes are *not*
      # removed from the current set.
      #
      # This method is intended to remove nodes from an XML document/node.
      def remove
        sets = []

        # First we gather all the sets to remove nodse from, then we remove the
        # actual nodes. This is done as you can not reliably remove elements
        # from an Array while iterating on that same Array.
        @nodes.each do |node|
          if node.node_set
            sets << node.node_set

            node.node_set = nil
            node.next     = nil
            node.previous = nil
          end
        end

        sets.each do |set|
          @nodes.each { |node| set.delete(node) }
        end
      end

      # Removes a node from the current set only.
      def delete(node)
        removed = @nodes.delete(node)

        if removed
          unmark_existing(removed)

          remove_ownership(removed) if @owner
        end

        removed
      end

      # Returns the values of the given attribute.
      #
      # @param [String|Symbol] name The name of the attribute.
      # @return [Array]
      def attribute(name)
        values = []

        @nodes.each do |node|
          if node.respond_to?(:attribute)
            values << node.attribute(name)
          end
        end

        values
      end

      alias_method :attr, :attribute

      # Returns the text of all nodes in the set, ignoring comment nodes.
      #
      # @return [String]
      def text
        text = ''

        @nodes.each do |node|
          if node.respond_to?(:text) and !node.is_a?(Comment)
            text << node.text
          end
        end

        text
      end

      # @return [String]
      def inspect
        values = @nodes.map(&:inspect).join(', ')

        "NodeSet(#{values})"
      end

      def take_ownership_on_nodes
        @nodes.each_with_index do |node, index|
          mark_existing(node)

          take_ownership(node, index) if @owner
        end
      end

      private

      # Takes ownership of the given node. This only occurs when the current
      # set has an owner.
      #
      # @param [Oga::XML::Node] node
      # @param [Fixnum] index
      def take_ownership(node, index)
        node.node_set = self

        node.previous = index > 0 ? @nodes[index - 1] : nil
        node.next = index + 1 < @nodes.length ? @nodes[index + 1] : nil

        node.previous.next = node if node.previous
        node.next.previous = node if node.next
      end

      # Removes ownership of the node if it belongs to the current set.
      #
      # @param [Oga::XML::Node] node
      def remove_ownership(node)
        return unless node.node_set == self

        if previous_node = node.previous
          previous_node.next = node.next
        end

        if next_node = node.next
          next_node.previous = node.previous
        end

        node.node_set = nil
        node.previous = nil
        node.next     = nil
      end

      # @param [Oga::XML::Node|Oga::XML::Attribute] node
      # @return [TrueClass|FalseClass]
      def exists?(node)
        @existing.key?(node)
      end

      # @param [Oga::XML::Node|Oga::XML::Attribute] node
      def mark_existing(node)
        @existing[node] = true
      end

      # @param [Oga::XML::Node|Oga::XML::Attribute] node
      def unmark_existing(node)
        @existing.delete(node)
      end
    end # NodeSet
  end # XML
end # Oga
