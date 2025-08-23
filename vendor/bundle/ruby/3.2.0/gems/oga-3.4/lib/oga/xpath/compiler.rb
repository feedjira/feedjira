module Oga
  module XPath
    # Compiling of XPath ASTs into Ruby code.
    #
    # The Compiler class can be used to turn an XPath AST into Ruby source code
    # that can be executed to match XML nodes in a given input document/element.
    # Compiled source code is cached per expression, removing the need for
    # recompiling the same expression over and over again.
    #
    # @private
    class Compiler
      # @return [Oga::LRU]
      CACHE = LRU.new

      # Context for compiled Procs. As compiled Procs do not mutate the
      # enclosing environment we can just re-use the same instance without
      # synchronization.
      CONTEXT = Context.new

      # Wildcard for node names/namespace prefixes.
      STAR = '*'

      # Node types that require a NodeSet to push nodes into.
      RETURN_NODESET = [:path, :absolute_path, :axis, :predicate]

      # Hash containing all operator callbacks, the conversion methods and the
      # Ruby methods to use.
      OPERATORS = {
        :on_add => [:to_float, :+],
        :on_sub => [:to_float, :-],
        :on_div => [:to_float, :/],
        :on_gt  => [:to_float, :>],
        :on_gte => [:to_float, :>=],
        :on_lt  => [:to_float, :<],
        :on_lte => [:to_float, :<=],
        :on_mul => [:to_float, :*],
        :on_mod => [:to_float, :%],
        :on_and => [:to_boolean, :and],
        :on_or  => [:to_boolean, :or]
      }

      # Compiles and caches an AST.
      #
      # @see [#compile]
      def self.compile_with_cache(ast, namespaces: nil)
        cache_key = namespaces ? [ast, namespaces] : ast
        CACHE.get_or_set(cache_key) { new(namespaces: namespaces).compile(ast) }
      end

      # @param [Hash] namespaces
      def initialize(namespaces: nil)
        reset

        @namespaces = namespaces
      end

      # Resets the internal state.
      def reset
        @literal_id = 0

        @predicate_nodesets = []
        @predicate_indexes  = []
      end

      # Compiles an XPath AST into a Ruby Proc.
      #
      # @param [AST::Node] ast
      # @return [Proc]
      def compile(ast)
        document = literal(:node)
        matched  = matched_literal

        if return_nodeset?(ast)
          ruby_ast = process(ast, document) { |node| matched.push(node) }
        else
          ruby_ast = process(ast, document)
        end

        vars = variables_literal.assign(self.nil)

        proc_ast = literal(:lambda).add_block(document, vars) do
          input_assign = original_input_literal.assign(document)

          if return_nodeset?(ast)
            body = matched.assign(literal(XML::NodeSet).new)
              .followed_by(ruby_ast)
              .followed_by(matched)
          else
            body = ruby_ast
          end

          input_assign.followed_by(body)
        end

        generator = Ruby::Generator.new
        source    = generator.process(proc_ast)

        CONTEXT.evaluate(source)
      ensure
        reset
      end

      # Processes a single XPath AST node.
      #
      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def process(ast, input, &block)
        send("on_#{ast.type}", ast, input, &block)
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_absolute_path(ast, input, &block)
        if ast.children.empty?
          matched_literal.push(input.root_node)
        else
          process(ast.children[0], input.root_node, &block)
        end
      end

      # Dispatches the processing of axes to dedicated methods. This works
      # similar to {#process} except the handler names are "on_axis_X" with "X"
      # being the axis name.
      #
      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis(ast, input, &block)
        name, test, following = *ast

        handler = name.gsub('-', '_')

        send(:"on_axis_#{handler}", test, input) do |matched|
          process_following_or_yield(following, matched, &block)
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_child(ast, input)
        child = unique_literal(:child)

        document_or_node(input).if_true do
          input.children.each.add_block(child) do
            process(ast, child).if_true { yield child }
          end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_attribute(ast, input)
        input.is_a?(XML::Element).if_true do
          attribute = unique_literal(:attribute)

          input.attributes.each.add_block(attribute) do
            name_match = match_name_and_namespace(ast, attribute)

            if name_match
              name_match.if_true { yield attribute }
            else
              yield attribute
            end
          end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_ancestor_or_self(ast, input)
        parent = unique_literal(:parent)

        process(ast, input).and(input.is_a?(XML::Node))
          .if_true { yield input }
          .followed_by do
            attribute_or_node(input).if_true do
              input.each_ancestor.add_block(parent) do
                process(ast, parent).if_true { yield parent }
              end
            end
          end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_ancestor(ast, input)
        parent = unique_literal(:parent)

        attribute_or_node(input).if_true do
          input.each_ancestor.add_block(parent) do
            process(ast, parent).if_true { yield parent }
          end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_descendant_or_self(ast, input)
        node = unique_literal(:descendant)

        document_or_node(input).if_true do
          process(ast, input)
            .if_true { yield input }
            .followed_by do
              input.each_node.add_block(node) do
                process(ast, node).if_true { yield node }
              end
            end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_descendant(ast, input)
        node = unique_literal(:descendant)

        document_or_node(input).if_true do
          input.each_node.add_block(node) do
            process(ast, node).if_true { yield node }
          end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_parent(ast, input)
        parent = unique_literal(:parent)

        attribute_or_node(input).if_true do
          parent.assign(input.parent).followed_by do
            process(ast, parent).if_true { yield parent }
          end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_self(ast, input)
        process(ast, input).if_true { yield input }
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_following_sibling(ast, input)
        orig_input = original_input_literal
        doc_node   = literal(:doc_node)
        check      = literal(:check)
        parent     = literal(:parent)
        root       = literal(:root)

        orig_input.is_a?(XML::Node)
          .if_true { root.assign(orig_input.parent) }
          .else    { root.assign(orig_input) }
          .followed_by do
            input.is_a?(XML::Node).and(input.parent)
              .if_true { parent.assign(input.parent) }
              .else    { parent.assign(self.nil) }
          end
          .followed_by(check.assign(self.false))
          .followed_by do
            document_or_node(root).if_true do
              root.each_node.add_block(doc_node) do
                doc_node.eq(input)
                  .if_true do
                    check.assign(self.true)
                      .followed_by(throw_message(:skip_children))
                  end
                  .followed_by do
                    check.not.or(parent != doc_node.parent).if_true do
                      send_message(:next)
                    end
                  end
                  .followed_by do
                    process(ast, doc_node).if_true { yield doc_node }
                  end
              end
            end
          end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_following(ast, input)
        orig_input = original_input_literal
        doc_node   = literal(:doc_node)
        check      = literal(:check)
        root       = literal(:root)

        orig_input.is_a?(XML::Node)
          .if_true { root.assign(orig_input.root_node) }
          .else    { root.assign(orig_input) }
          .followed_by(check.assign(self.false))
          .followed_by do
            document_or_node(root).if_true do
              root.each_node.add_block(doc_node) do
                doc_node.eq(input)
                  .if_true do
                    check.assign(self.true)
                      .followed_by(throw_message(:skip_children))
                  end
                  .followed_by do
                    check.if_false { send_message(:next) }
                  end
                  .followed_by do
                    process(ast, doc_node).if_true { yield doc_node }
                  end
              end
            end
          end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_namespace(ast, input)
        underscore = literal(:_)
        node       = unique_literal(:namespace)

        name = string(ast.children[1])
        star = string(STAR)

        input.is_a?(XML::Element).if_true do
          input.available_namespaces.each.add_block(underscore, node) do
            node.name.eq(name).or(name.eq(star)).if_true { yield node }
          end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_preceding(ast, input)
        root     = literal(:root)
        doc_node = literal(:doc_node)

        input.is_a?(XML::Node).if_true do
          root.assign(input.root_node)
            .followed_by do
              document_or_node(root).if_true do
                root.each_node.add_block(doc_node) do
                  doc_node.eq(input)
                    .if_true { self.break }
                    .followed_by do
                      process(ast, doc_node).if_true { yield doc_node }
                    end
                end
              end
            end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_axis_preceding_sibling(ast, input)
        orig_input = original_input_literal
        check      = literal(:check)
        root       = literal(:root)
        parent     = literal(:parent)
        doc_node   = literal(:doc_node)

        orig_input.is_a?(XML::Node)
          .if_true { root.assign(orig_input.parent) }
          .else    { root.assign(orig_input) }
          .followed_by(check.assign(self.false))
          .followed_by do
            input.is_a?(XML::Node).and(input.parent)
              .if_true { parent.assign(input.parent) }
              .else    { parent.assign(self.nil) }
          end
          .followed_by do
            document_or_node(root).if_true do
              root.each_node.add_block(doc_node) do
                doc_node.eq(input)
                  .if_true { self.break }
                  .followed_by do
                    doc_node.parent.eq(parent).if_true do
                      process(ast, doc_node).if_true { yield doc_node }
                    end
                  end
              end
            end
          end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_predicate(ast, input, &block)
        test, predicate, following = *ast

        index_var = unique_literal(:index)

        if number?(predicate)
          method = :on_predicate_index
        elsif has_call_node?(predicate, 'last')
          method = :on_predicate_temporary
        else
          method = :on_predicate_direct
        end

        @predicate_indexes << index_var

        ast = index_var.assign(literal(1)).followed_by do
          send(method, input, test, predicate) do |matched|
            process_following_or_yield(following, matched, &block)
          end
        end

        @predicate_indexes.pop

        ast
      end

      # Processes a predicate that requires a temporary NodeSet.
      #
      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] test
      # @param [AST::Node] predicate
      # @return [Oga::Ruby::Node]
      def on_predicate_temporary(input, test, predicate)
        temp_set   = unique_literal(:temp_set)
        pred_node  = unique_literal(:pred_node)
        pred_var   = unique_literal(:pred_var)
        conversion = literal(Conversion)

        index_var  = predicate_index
        index_step = literal(1)

        @predicate_nodesets << temp_set

        ast = temp_set.assign(literal(XML::NodeSet).new)
          .followed_by do
            process(test, input) { |node| temp_set << node }
          end
          .followed_by do
            temp_set.each.add_block(pred_node) do
              pred_ast = process(predicate, pred_node)

              pred_var.assign(pred_ast)
                .followed_by do
                  pred_var.is_a?(Numeric).if_true do
                    pred_var.assign(pred_var.to_i.eq(index_var))
                  end
                end
                .followed_by do
                  conversion.to_boolean(pred_var).if_true { yield pred_node }
                end
                .followed_by do
                  index_var.assign(index_var + index_step)
                end
            end
          end

        @predicate_nodesets.pop

        ast
      end

      # Processes a predicate that doesn't require temporary NodeSet.
      #
      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] test
      # @param [AST::Node] predicate
      # @return [Oga::Ruby::Node]
      def on_predicate_direct(input, test, predicate)
        pred_var   = unique_literal(:pred_var)
        index_var  = predicate_index
        index_step = literal(1)
        conversion = literal(Conversion)

        process(test, input) do |matched_test_node|
          if return_nodeset?(predicate)
            pred_ast = catch_message(:predicate_matched) do
              process(predicate, matched_test_node) do
                throw_message(:predicate_matched, self.true)
              end
            end
          else
            pred_ast = process(predicate, matched_test_node)
          end

          pred_var.assign(pred_ast)
            .followed_by do
              pred_var.is_a?(Numeric).if_true do
                pred_var.assign(pred_var.to_i.eq(index_var))
              end
            end
            .followed_by do
              conversion.to_boolean(pred_var).if_true do
                yield matched_test_node
              end
            end
            .followed_by do
              index_var.assign(index_var + index_step)
            end
        end
      end

      # Processes a predicate that uses a literal index.
      #
      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] test
      # @param [AST::Node] predicate
      # @return [Oga::Ruby::Node]
      def on_predicate_index(input, test, predicate)
        index_var  = predicate_index
        index_step = literal(1)

        index = process(predicate, input).to_i

        process(test, input) do |matched_test_node|
          index_var.eq(index)
            .if_true do
              yield matched_test_node
            end
            .followed_by do
              index_var.assign(index_var + index_step)
            end
        end
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_test(ast, input)
        condition  = element_or_attribute(input)
        name_match = match_name_and_namespace(ast, input)

        name_match ? condition.and(name_match) : condition
      end

      # Processes the `=` operator.
      #
      # @see [#operator]
      def on_eq(ast, input, &block)
        conv = literal(Conversion)

        operator(ast, input) do |left, right|
          mass_assign([left, right], conv.to_compatible_types(left, right))
            .followed_by do
              operation = left.eq(right)

              block ? operation.if_true(&block) : operation
            end
        end
      end

      # Processes the `!=` operator.
      #
      # @see [#operator]
      def on_neq(ast, input, &block)
        conv = literal(Conversion)

        operator(ast, input) do |left, right|
          mass_assign([left, right], conv.to_compatible_types(left, right))
            .followed_by do
              operation = left != right

              block ? operation.if_true(&block) : operation
            end
        end
      end

      OPERATORS.each do |callback, (conv_method, ruby_method)|
        define_method(callback) do |ast, input, &block|
          conversion = literal(XPath::Conversion)

          operator(ast, input) do |left, right|
            lval      = conversion.__send__(conv_method, left)
            rval      = conversion.__send__(conv_method, right)
            operation = lval.__send__(ruby_method, rval)

            block ? conversion.to_boolean(operation).if_true(&block) : operation
          end
        end
      end

      # Processes the `|` operator.
      #
      # @see [#operator]
      def on_pipe(ast, input, &block)
        left, right = *ast

        union = unique_literal(:union)

        # Expressions such as "a | b | c"
        if left.type == :pipe
          union.assign(process(left, input))
            .followed_by(process(right, input) { |node| union << node })
            .followed_by(union)
        # Expressions such as "a | b"
        else
          union.assign(literal(XML::NodeSet).new)
            .followed_by(process(left, input) { |node| union << node })
            .followed_by(process(right, input) { |node| union << node })
            .followed_by(union)
        end
      end

      # @param [AST::Node] ast
      # @return [Oga::Ruby::Node]
      def on_string(ast, *)
        string(ast.children[0])
      end

      # @param [AST::Node] ast
      # @return [Oga::Ruby::Node]
      def on_int(ast, *)
        literal(ast.children[0].to_f.to_s)
      end

      # @param [AST::Node] ast
      # @return [Oga::Ruby::Node]
      def on_float(ast, *)
        literal(ast.children[0].to_s)
      end

      # @param [AST::Node] ast
      # @return [Oga::Ruby::Node]
      def on_var(ast, *)
        name = ast.children[0]

        variables_literal.and(variables_literal[string(name)])
          .or(send_message(:raise, string("Undefined XPath variable: #{name}")))
      end

      # Delegates function calls to specific handlers.
      #
      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_call(ast, input, &block)
        name, *args = *ast

        handler = name.gsub('-', '_')

        send(:"on_call_#{handler}", input, *args, &block)
      end

      # @return [Oga::Ruby::Node]
      def on_call_true(*)
        block_given? ? yield : self.true
      end

      # @return [Oga::Ruby::Node]
      def on_call_false(*)
        self.false
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_boolean(input, arg)
        arg_ast    = try_match_first_node(arg, input)
        call_arg   = unique_literal(:call_arg)
        conversion = literal(Conversion)

        call_arg.assign(arg_ast).followed_by do
          converted = conversion.to_boolean(call_arg)

          block_given? ? converted.if_true { yield } : converted
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_ceiling(input, arg)
        arg_ast    = try_match_first_node(arg, input)
        call_arg   = unique_literal(:call_arg)
        conversion = literal(Conversion)

        call_arg.assign(arg_ast)
          .followed_by do
            call_arg.assign(conversion.to_float(call_arg))
          end
          .followed_by do
            call_arg.nan?
              .if_true { call_arg }
              .else    { block_given? ? yield : call_arg.ceil.to_f }
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_floor(input, arg)
        arg_ast    = try_match_first_node(arg, input)
        call_arg   = unique_literal(:call_arg)
        conversion = literal(Conversion)

        call_arg.assign(arg_ast)
          .followed_by do
            call_arg.assign(conversion.to_float(call_arg))
          end
          .followed_by do
            call_arg.nan?
              .if_true { call_arg }
              .else    { block_given? ? yield : call_arg.floor.to_f }
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_round(input, arg)
        arg_ast    = try_match_first_node(arg, input)
        call_arg   = unique_literal(:call_arg)
        conversion = literal(Conversion)

        call_arg.assign(arg_ast)
          .followed_by do
            call_arg.assign(conversion.to_float(call_arg))
          end
          .followed_by do
            call_arg.nan?
              .if_true { call_arg }
              .else    { block_given? ? yield : call_arg.round.to_f }
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [Array<AST::Node>] args
      # @return [Oga::Ruby::Node]
      def on_call_concat(input, *args)
        conversion  = literal(Conversion)
        assigns     = []
        conversions = []

        args.each do |arg|
          arg_var = unique_literal(:concat_arg)
          arg_ast = try_match_first_node(arg, input)

          assigns     << arg_var.assign(arg_ast)
          conversions << conversion.to_string(arg_var)
        end

        concatted = assigns.inject(:followed_by)
          .followed_by(conversions.inject(:+))

        block_given? ? concatted.empty?.if_false { yield } : concatted
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] haystack
      # @param [AST::Node] needle
      # @return [Oga::Ruby::Node]
      def on_call_contains(input, haystack, needle)
        haystack_lit = unique_literal(:haystack)
        needle_lit   = unique_literal(:needle)
        conversion   = literal(Conversion)

        haystack_lit.assign(try_match_first_node(haystack, input))
          .followed_by do
            needle_lit.assign(try_match_first_node(needle, input))
          end
          .followed_by do
            converted = conversion.to_string(haystack_lit)
              .include?(conversion.to_string(needle_lit))

            block_given? ? converted.if_true { yield } : converted
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_count(input, arg)
        count = unique_literal(:count)

        unless return_nodeset?(arg)
          raise TypeError, 'count() can only operate on NodeSet instances'
        end

        count.assign(literal(0.0))
          .followed_by do
            process(arg, input) { count.assign(count + literal(1)) }
          end
          .followed_by do
            block_given? ? count.zero?.if_false { yield } : count
          end
      end

      # Processes the `id()` function call.
      #
      # The XPath specification states that this function's behaviour should be
      # controlled by a DTD. If a DTD were to specify that the ID attribute for
      # a certain element would be "foo" then this function should use said
      # attribute.
      #
      # Oga does not support DTD parsing/evaluation and as such always uses the
      # "id" attribute.
      #
      # This function searches the entire document for a matching node,
      # regardless of the current position.
      #
      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_id(input, arg)
        orig_input = original_input_literal
        node       = unique_literal(:node)
        ids_var    = unique_literal('ids')
        matched    = unique_literal('id_matched')
        id_str_var = unique_literal('id_string')
        attr_var   = unique_literal('attr')

        matched.assign(literal(XML::NodeSet).new)
          .followed_by do
            # When using some sort of path we'll want the text of all matched
            # nodes.
            if return_nodeset?(arg)
              ids_var.assign(literal(:[])).followed_by do
                process(arg, input) { |element| ids_var << element.text }
              end

            # For everything else we'll cast the value to a string and split it
            # on every space.
            else
              conversion = literal(Conversion).to_string(ids_var)
                .split(string(' '))

              ids_var.assign(process(arg, input))
                .followed_by(ids_var.assign(conversion))
            end
          end
          .followed_by do
            id_str_var.assign(string('id'))
          end
          .followed_by do
            orig_input.each_node.add_block(node) do
              node.is_a?(XML::Element).if_true do
                attr_var.assign(node.attribute(id_str_var)).followed_by do
                  attr_var.and(ids_var.include?(attr_var.value))
                    .if_true { block_given? ? yield : matched << node }
                end
              end
            end
          end
          .followed_by(matched)
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_lang(input, arg)
        lang_var = unique_literal('lang')
        node     = unique_literal('node')
        found    = unique_literal('found')
        xml_lang = unique_literal('xml_lang')
        matched  = unique_literal('matched')

        conversion = literal(Conversion)

        ast = lang_var.assign(try_match_first_node(arg, input))
          .followed_by do
            lang_var.assign(conversion.to_string(lang_var))
          end
          .followed_by do
            matched.assign(self.false)
          end
          .followed_by do
            node.assign(input)
          end
          .followed_by do
            xml_lang.assign(string('xml:lang'))
          end
          .followed_by do
            node.respond_to?(symbol(:attribute)).while_true do
              found.assign(node.get(xml_lang))
                .followed_by do
                  found.if_true do
                    found.eq(lang_var)
                      .if_true do
                        if block_given?
                          yield
                        else
                          matched.assign(self.true).followed_by(self.break)
                        end
                      end
                      .else { self.break }
                  end
                end
                .followed_by(node.assign(node.parent))
            end
          end

        block_given? ? ast : ast.followed_by(matched)
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_local_name(input, arg = nil)
        argument_or_first_node(input, arg) do |arg_var|
          arg_var
            .if_true do
              ensure_element_or_attribute(arg_var)
                .followed_by { block_given? ? yield : arg_var.name }
            end
            .else { string('') }
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_name(input, arg = nil)
        argument_or_first_node(input, arg) do |arg_var|
          arg_var
            .if_true do
              ensure_element_or_attribute(arg_var)
                .followed_by { block_given? ? yield : arg_var.expanded_name }
            end
            .else { string('') }
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_namespace_uri(input, arg = nil)
        default = string('')

        argument_or_first_node(input, arg) do |arg_var|
          arg_var
            .if_true do
              ensure_element_or_attribute(arg_var).followed_by do
                arg_var.namespace
                  .if_true { block_given? ? yield : arg_var.namespace.uri }
                  .else    { default } # no yield so predicates aren't matched
              end
            end
            .else { default }
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_normalize_space(input, arg = nil)
        conversion = literal(Conversion)
        norm_var   = unique_literal(:normalized)

        find    = literal('/\s+/')
        replace = string(' ')

        argument_or_first_node(input, arg) do |arg_var|
          norm_var
            .assign(conversion.to_string(arg_var).strip.gsub(find, replace))
            .followed_by do
              norm_var.empty?
                .if_true { string('') }
                .else    { block_given? ? yield : norm_var }
            end
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_not(input, arg)
        arg_ast    = try_match_first_node(arg, input)
        call_arg   = unique_literal(:call_arg)
        conversion = literal(Conversion)

        call_arg.assign(arg_ast).followed_by do
          converted = conversion.to_boolean(call_arg).not

          block_given? ? converted.if_true { yield } : converted
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_number(input, arg = nil)
        convert_var = unique_literal(:convert)
        conversion  = literal(Conversion)

        argument_or_first_node(input, arg) do |arg_var|
          convert_var.assign(conversion.to_float(arg_var)).followed_by do
            if block_given?
              convert_var.zero?.if_false { yield }
            else
              convert_var
            end
          end
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] haystack
      # @param [AST::Node] needle
      # @return [Oga::Ruby::Node]
      def on_call_starts_with(input, haystack, needle)
        haystack_var = unique_literal(:haystack)
        needle_var   = unique_literal(:needle)
        conversion   = literal(Conversion)

        haystack_var.assign(try_match_first_node(haystack, input))
          .followed_by do
            needle_var.assign(try_match_first_node(needle, input))
          end
          .followed_by do
            haystack_var.assign(conversion.to_string(haystack_var))
              .followed_by do
                needle_var.assign(conversion.to_string(needle_var))
              end
              .followed_by do
                equal = needle_var.empty?
                  .or(haystack_var.start_with?(needle_var))

                block_given? ? equal.if_true { yield } : equal
              end
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_string_length(input, arg = nil)
        convert_var = unique_literal(:convert)
        conversion  = literal(Conversion)

        argument_or_first_node(input, arg) do |arg_var|
          convert_var.assign(conversion.to_string(arg_var).length)
            .followed_by do
              if block_given?
                convert_var.zero?.if_false { yield }
              else
                convert_var.to_f
              end
            end
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_string(input, arg = nil)
        convert_var = unique_literal(:convert)
        conversion  = literal(Conversion)

        argument_or_first_node(input, arg) do |arg_var|
          convert_var.assign(conversion.to_string(arg_var))
            .followed_by do
              if block_given?
                convert_var.empty?.if_false { yield }
              else
                convert_var
              end
            end
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] haystack
      # @param [AST::Node] needle
      # @return [Oga::Ruby::Node]
      def on_call_substring_before(input, haystack, needle)
        haystack_var = unique_literal(:haystack)
        needle_var   = unique_literal(:needle)
        conversion   = literal(Conversion)

        before = unique_literal(:before)
        sep    = unique_literal(:sep)
        after  = unique_literal(:after)

        haystack_var.assign(try_match_first_node(haystack, input))
          .followed_by do
            needle_var.assign(try_match_first_node(needle, input))
          end
          .followed_by do
            converted = conversion.to_string(haystack_var)
              .partition(conversion.to_string(needle_var))

            mass_assign([before, sep, after], converted).followed_by do
              sep.empty?
                .if_true { sep }
                .else    { block_given? ? yield : before }
            end
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] haystack
      # @param [AST::Node] needle
      # @return [Oga::Ruby::Node]
      def on_call_substring_after(input, haystack, needle)
        haystack_var = unique_literal(:haystack)
        needle_var   = unique_literal(:needle)
        conversion   = literal(Conversion)

        before = unique_literal(:before)
        sep    = unique_literal(:sep)
        after  = unique_literal(:after)

        haystack_var.assign(try_match_first_node(haystack, input))
          .followed_by do
            needle_var.assign(try_match_first_node(needle, input))
          end
          .followed_by do
            converted = conversion.to_string(haystack_var)
              .partition(conversion.to_string(needle_var))

            mass_assign([before, sep, after], converted).followed_by do
              sep.empty?
                .if_true { sep }
                .else    { block_given? ? yield : after }
            end
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] haystack
      # @param [AST::Node] start
      # @param [AST::Node] length
      # @return [Oga::Ruby::Node]
      def on_call_substring(input, haystack, start, length = nil)
        haystack_var = unique_literal(:haystack)
        start_var    = unique_literal(:start)
        stop_var     = unique_literal(:stop)
        length_var   = unique_literal(:length)
        conversion   = literal(Conversion)

        haystack_var.assign(try_match_first_node(haystack, input))
          .followed_by do
            start_var.assign(try_match_first_node(start, input))
              .followed_by do
                start_var.assign(start_var - literal(1))
              end
          end
          .followed_by do
            if length
              length_var.assign(try_match_first_node(length, input))
                .followed_by do
                  length_int = conversion.to_float(length_var)
                    .to_i - literal(1)

                  stop_var.assign(start_var + length_int)
                end
            else
              stop_var.assign(literal(-1))
            end
          end
          .followed_by do
            substring = conversion
              .to_string(haystack_var)[range(start_var, stop_var)]

            block_given? ? substring.empty?.if_false { yield } : substring
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] arg
      # @return [Oga::Ruby::Node]
      def on_call_sum(input, arg)
        unless return_nodeset?(arg)
          raise TypeError, 'sum() can only operate on a path, axis or predicate'
        end

        sum_var    = unique_literal(:sum)
        conversion = literal(Conversion)

        sum_var.assign(literal(0.0))
          .followed_by do
            process(arg, input) do |matched_node|
              sum_var.assign(sum_var + conversion.to_float(matched_node.text))
            end
          end
          .followed_by do
            block_given? ? sum_var.zero?.if_false { yield } : sum_var
          end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Node] source
      # @param [AST::Node] find
      # @param [AST::Node] replace
      # @return [Oga::Ruby::Node]
      def on_call_translate(input, source, find, replace)
        source_var   = unique_literal(:source)
        find_var     = unique_literal(:find)
        replace_var  = unique_literal(:replace)
        replaced_var = unique_literal(:replaced)
        conversion   = literal(Conversion)

        char  = unique_literal(:char)
        index = unique_literal(:index)

        source_var.assign(try_match_first_node(source, input))
          .followed_by do
            replaced_var.assign(conversion.to_string(source_var))
          end
          .followed_by do
            find_var.assign(try_match_first_node(find, input))
          end
          .followed_by do
            find_var.assign(conversion.to_string(find_var).chars.to_array)
          end
          .followed_by do
            replace_var.assign(try_match_first_node(replace, input))
          end
          .followed_by do
            replace_var.assign(conversion.to_string(replace_var).chars.to_array)
          end
          .followed_by do
            find_var.each_with_index.add_block(char, index) do
              replace_with = replace_var[index]
                .if_true { replace_var[index] }
                .else    { string('') }

              replaced_var.assign(replaced_var.gsub(char, replace_with))
            end
          end
          .followed_by do
            replaced_var
          end
      end

      # @return [Oga::Ruby::Node]
      def on_call_last(*)
        set = predicate_nodeset

        unless set
          raise 'last() can only be used in a predicate'
        end

        set.length.to_f
      end

      # @return [Oga::Ruby::Node]
      def on_call_position(*)
        index = predicate_index

        unless index
          raise 'position() can only be used in a predicate'
        end

        index.to_f
      end

      # Delegates type tests to specific handlers.
      #
      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_type_test(ast, input, &block)
        name, following = *ast

        handler = name.gsub('-', '_')

        send(:"on_type_test_#{handler}", input) do |matched|
          process_following_or_yield(following, matched, &block)
        end
      end

      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_type_test_comment(input)
        input.is_a?(XML::Comment)
      end

      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_type_test_text(input)
        input.is_a?(XML::Text)
      end

      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_type_test_processing_instruction(input)
        input.is_a?(XML::ProcessingInstruction)
      end

      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def on_type_test_node(input)
        document_or_node(input).or(input.is_a?(XML::Attribute))
      end

      # @param [#to_s] value
      # @return [Oga::Ruby::Node]
      def literal(value)
        Ruby::Node.new(:lit, [value.to_s])
      end

      # @param [Oga::Ruby::Node] start
      # @param [Oga::Ruby::Node] stop
      # @return [Oga::Ruby::Node]
      def range(start, stop)
        Ruby::Node.new(:range, [start, stop])
      end

      # @param [String] name
      # @return [Oga::Ruby::Node]
      def unique_literal(name)
        new_id = @literal_id += 1

        literal("#{name}#{new_id}")
      end

      # @param [#to_s] value
      # @return [Oga::Ruby::Node]
      def string(value)
        Ruby::Node.new(:string, [value.to_s])
      end

      # @param [String] value
      # @return [Oga::Ruby::Node]
      def symbol(value)
        Ruby::Node.new(:symbol, [value.to_sym])
      end

      # @param [String] name
      # @param [Array] args
      # @return [Oga::Ruby::Node]
      def send_message(name, *args)
        Ruby::Node.new(:send, [nil, name.to_s, *args])
      end

      # @param [Class] klass
      # @param [String] message
      # @return [Oga::Ruby::Node]
      def raise_message(klass, message)
        send_message(:raise, literal(klass), string(message))
      end

      # @return [Oga::Ruby::Node]
      def nil
        @nil ||= literal(:nil)
      end

      # @return [Oga::Ruby::Node]
      def true
        @true ||= literal(:true)
      end

      # @return [Oga::Ruby::Node]
      def false
        @false ||= literal(:false)
      end

      # @param [Oga::Ruby::Node] node
      # @return [Oga::Ruby::Node]
      def element_or_attribute(node)
        node.is_a?(XML::Element).or(node.is_a?(XML::Attribute))
      end

      # @param [Oga::Ruby::Node] node
      # @return [Oga::Ruby::Node]
      def attribute_or_node(node)
        node.is_a?(XML::Attribute).or(node.is_a?(XML::Node))
      end

      # @param [Oga::Ruby::Node] node
      # @return [Oga::Ruby::Node]
      def document_or_node(node)
        node.is_a?(XML::Document).or(node.is_a?(XML::Node))
      end

      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def match_name_and_namespace(ast, input)
        ns, name = *ast

        condition = nil
        name_str  = string(name)
        zero      = literal(0)

        if name != STAR
          condition = input.name.eq(name_str)
            .or(input.name.casecmp(name_str).eq(zero))
        end

        if ns and ns != STAR
          if @namespaces
            ns_uri = @namespaces[ns]
            ns_match =
              if ns_uri
                input.namespace.and(input.namespace.uri.eq(string(ns_uri)))
              else
                self.false
              end
          else
            ns_match =
              if ns == XML::Element::XMLNS_PREFIX
                input
              else
                input.namespace_name.eq(string(ns))
              end
          end

          condition = condition ? condition.and(ns_match) : ns_match
        end

        condition
      end

      # Returns an AST matching the first node of a node set.
      #
      # @param [Oga::Ruby::Node] ast
      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def match_first_node(ast, input)
        catch_message(:value) do
          process(ast, input) do |node|
            throw_message(:value, node)
          end
        end
      end

      # Tries to match the first node in a set, otherwise processes it as usual.
      #
      # @see [#match_first_node]
      def try_match_first_node(ast, input, optimize_first = true)
        if return_nodeset?(ast) and optimize_first
          match_first_node(ast, input)
        else
          process(ast, input)
        end
      end

      # @param [Oga::Ruby::Node] input
      # @return [Oga::Ruby::Node]
      def ensure_element_or_attribute(input)
        element_or_attribute(input).if_false do
          raise_message(TypeError, 'argument is not an Element or Attribute')
        end
      end

      # @param [Oga::Ruby::Node] input
      # @param [AST::Ruby] arg
      # @return [Oga::Ruby::Node]
      def argument_or_first_node(input, arg = nil)
        arg_ast = arg ? try_match_first_node(arg, input) : input
        arg_var = unique_literal(:argument_or_first_node)

        arg_var.assign(arg_ast).followed_by { yield arg_var }
      end

      # Generates the code for an operator.
      #
      # The generated code is optimized so that expressions such as `a/b = c`
      # only match the first node in both arms instead of matching all available
      # nodes first. Because numeric operators only ever operates on the first
      # node in a set we can simply ditch the rest, possibly speeding things up
      # quite a bit. This only works if one of the arms is:
      #
      # * a path
      # * an axis
      # * a predicate
      #
      # Everything else is processed the usual (and possibly slower) way.
      #
      # @param [AST::Node] ast
      # @param [Oga::Ruby::Node] input
      # @param [TrueClass|FalseClass] optimize_first
      # @return [Oga::Ruby::Node]
      def operator(ast, input, optimize_first = true)
        left, right = *ast

        left_var  = unique_literal(:op_left)
        right_var = unique_literal(:op_right)

        left_ast  = try_match_first_node(left, input, optimize_first)
        right_ast = try_match_first_node(right, input, optimize_first)

        left_var.assign(left_ast)
          .followed_by(right_var.assign(right_ast))
          .followed_by { yield left_var, right_var }
      end

      # @return [Oga::Ruby::Node]
      def matched_literal
        literal(:matched)
      end

      # @return [Oga::Ruby::Node]
      def original_input_literal
        literal(:original_input)
      end

      # @return [Oga::Ruby::Node]
      def variables_literal
        literal(:variables)
      end

      # @param [AST::Node] ast
      # @return [Oga::Ruby::Node]
      def to_int(ast)
        literal(ast.children[0].to_i.to_s)
      end

      # @param [Array] vars The variables to assign.
      # @param [Oga::Ruby::Node] value
      # @return [Oga::Ruby::Node]
      def mass_assign(vars, value)
        Ruby::Node.new(:massign, [vars, value])
      end

      # @param [AST::Node] ast
      # @return [TrueClass|FalseClass]
      def number?(ast)
        ast.type == :int || ast.type == :float
      end

      # @param [AST::Node] ast
      # @return [TrueClass|FalseClass]
      def string?(ast)
        ast.type == :string
      end

      # @param [Symbol] name
      # @return [Oga::Ruby::Node]
      def catch_message(name)
        send_message(:catch, symbol(name)).add_block do
          # Ensure that the "catch" only returns a value when "throw" is
          # actually invoked.
          yield.followed_by(self.nil)
        end
      end

      # @param [Symbol] name
      # @param [Array] args
      # @return [Oga::Ruby::Node]
      def throw_message(name, *args)
        send_message(:throw, symbol(name), *args)
      end

      # @return [Oga::Ruby::Node]
      def break
        send_message(:break)
      end

      # @param [AST::Node] ast
      # @return [TrueClass|FalseClass]
      def return_nodeset?(ast)
        RETURN_NODESET.include?(ast.type)
      end

      # @param [AST::Node] ast
      # @return [TrueClass|FalseClass]
      def has_call_node?(ast, name)
        visit = [ast]

        until visit.empty?
          current = visit.pop

          return true if current.type == :call && current.children[0] == name

          current.children.each do |child|
            visit << child if child.is_a?(AST::Node)
          end
        end

        false
      end

      # @return [Oga::Ruby::Node]
      def predicate_index
        @predicate_indexes.last
      end

      # @return [Oga::Ruby::Node]
      def predicate_nodeset
        @predicate_nodesets.last
      end

      # @param [AST::Node] following
      # @param [Oga::Ruby::Node] matched
      # @return [Oga::Ruby::Node]
      def process_following_or_yield(following, matched, &block)
        if following
          process(following, matched, &block)
        else
          yield matched
        end
      end
    end # Compiler
  end # XPath
end # Oga
