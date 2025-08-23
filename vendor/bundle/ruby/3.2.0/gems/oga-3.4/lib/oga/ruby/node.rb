module Oga
  module Ruby
    # Class representing a single node in a Ruby AST.
    #
    # The setup of this class is roughly based on the "ast" Gem. The "ast" Gem
    # is not used for this class as it provides too many methods that might
    # conflict with this class' {#method_missing}.
    #
    # ASTs can be built by creating a node and then chaining various method
    # calls together. For example, the following could be used to build an "if"
    # statement:
    #
    #     number1 = Node.new(:lit, %w{10})
    #     number2 = Node.new(:lit, %w{20})
    #
    #     (number2 > number1).if_true do
    #       Node.new(:lit, %w{30})
    #     end
    #
    # When serialized to Ruby this would roughly lead to the following code:
    #
    #     if 20 > 10
    #       30
    #     end
    #
    # @private
    class Node < BasicObject
      undef_method :!, :!=

      # @return [Symbol]
      attr_reader :type

      # @param [Symbol] type
      # @param [Array] children
      def initialize(type, children = [])
        @type     = type.to_sym
        @children = children
      end

      # @return [Array]
      def to_a
        @children
      end

      alias_method :to_ary, :to_a

      # Returns a "to_a" call node.
      #
      # @return [Oga::Ruby::Node]
      def to_array
        Node.new(:send, [self, :to_a])
      end

      # Returns an assignment node.
      #
      # This method wraps assigned values in a begin/end block to ensure that
      # multiple lines of code result in the proper value being assigned.
      #
      # @param [Oga::Ruby::Node] other
      # @return [Oga::Ruby::Node]
      def assign(other)
        if other.type == :followed_by
          other = other.wrap
        end

        Node.new(:assign, [self, other])
      end

      # Returns an equality expression node.
      #
      # @param [Oga::Ruby::Node] other
      # @return [Oga::Ruby::Node]
      def eq(other)
        Node.new(:eq, [self, other])
      end

      # Returns a boolean "and" node.
      #
      # @param [Oga::Ruby::Node] other
      # @return [Oga::Ruby::Node]
      def and(other)
        Node.new(:and, [self, other])
      end

      # Returns a boolean "or" node.
      #
      # @param [Oga::Ruby::Node] other
      # @return [Oga::Ruby::Node]
      def or(other)
        Node.new(:or, [self, other])
      end

      # Returns a node that evaluates to its inverse.
      #
      # For example, a variable `foo` would be turned into `!foo`.
      #
      # @return [Oga::Ruby::Node]
      def not
        !self
      end

      # Returns a node for Ruby's "is_a?" method.
      #
      # @param [Class] klass
      # @return [Oga::Ruby::Node]
      def is_a?(klass)
        Node.new(:send, [self, 'is_a?', Node.new(:lit, [klass.to_s])])
      end

      # Wraps the current node in a block.
      #
      # @param [Array] args Arguments (as Node instances) to pass to the block.
      # @return [Oga::Ruby::Node]
      def add_block(*args)
        Node.new(:block, [self, args, yield])
      end

      # Wraps the current node in a `begin` node.
      #
      # @return [Oga::Ruby::Node]
      def wrap
        Node.new(:begin, [self])
      end

      # Wraps the current node in an if statement node.
      #
      # The body of this statement is set to the return value of the supplied
      # block.
      #
      # @return [Oga::Ruby::Node]
      def if_true
        Node.new(:if, [self, yield])
      end

      # Wraps the current node in an `if !...` statement.
      #
      # @see [#if_true]
      def if_false
        self.not.if_true { yield }
      end

      # Wraps the current node in a `while` statement.
      #
      # The body of this statement is set to the return value of the supplied
      # block.
      #
      # @return [Oga::Ruby::Node]
      def while_true
        Node.new(:while, [self, yield])
      end

      # Adds an "else" statement to the current node.
      #
      # This method assumes it's being called only on "if" nodes.
      #
      # @return [Oga::Ruby::Node]
      def else
        Node.new(:if, @children + [yield])
      end

      # Chains two nodes together.
      #
      # @param [Oga::Ruby::Node] other
      # @return [Oga::Ruby::Node]
      def followed_by(other = nil)
        other = yield if ::Kernel.block_given?

        Node.new(:followed_by, [self, other])
      end

      # Returns a node for a method call.
      #
      # @param [Symbol] name The name of the method to call.
      #
      # @param [Array] args Any arguments (as Node instances) to pass to the
      #  method.
      #
      # @return [Oga::Ruby::Node]
      def method_missing(name, *args)
        Node.new(:send, [self, name.to_s, *args])
      end

      # @return [String]
      def inspect
        "(#{type} #{@children.map(&:inspect).join(' ')})"
      end
    end # Node
  end # Ruby
end # Oga
