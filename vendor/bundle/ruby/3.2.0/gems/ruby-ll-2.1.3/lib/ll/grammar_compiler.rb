module LL
  ##
  # The GrammarCompiler class processes an AST (as parsed from an LL(1) grammar)
  # and returns an {LL::CompiledGrammar} instance.
  #
  class GrammarCompiler
    ##
    # @param [LL::AST::Node] ast
    # @return [LL::CompiledGrammar]
    #
    def compile(ast)
      compiled = CompiledGrammar.new

      process(ast, compiled)

      warn_for_unused_terminals(compiled)
      warn_for_unused_rules(compiled)

      verify_first_first(compiled)
      verify_first_follow(compiled)

      return compiled
    end

    ##
    # @param [LL::AST::Node] node
    # @param [LL::CompiledGrammar] compiled_grammar
    # @return [LL::CompiledGrammar]
    #
    def process(node, compiled_grammar)
      handler = "on_#{node.type}"

      return send(handler, node, compiled_grammar)
    end

    ##
    # Adds warnings for any unused rules. The first defined rule is skipped
    # since it's the root rule.
    #
    # @param [LL::CompiledGrammar] compiled_grammar
    #
    def warn_for_unused_rules(compiled_grammar)
      compiled_grammar.rules.each_with_index do |rule, index|
        next if index == 0 || rule.references > 0

        compiled_grammar.add_warning(
          "Unused rule #{rule.name.inspect}",
          rule.source_line
        )
      end
    end

    ##
    # Adds warnings for any unused terminals.
    #
    # @param [LL::CompiledGrammar] compiled_grammar
    #
    def warn_for_unused_terminals(compiled_grammar)
      compiled_grammar.terminals.each do |terminal|
        next if terminal.references > 0

        compiled_grammar.add_warning(
          "Unused terminal #{terminal.name.inspect}",
          terminal.source_line
        )
      end
    end

    ##
    # Verifies all rules to see if they don't have any first/first conflicts.
    # Errors are added for every rule where this _is_ the case.
    #
    # @param [LL::CompiledGrammar] compiled_grammar
    #
    def verify_first_first(compiled_grammar)
      compiled_grammar.rules.each do |rule|
        conflicting = Set.new

        rule.branches.each do |branch|
          next if conflicting.include?(branch)

          rule.branches.each do |other_branch|
            next if branch == other_branch || conflicting.include?(other_branch)

            overlapping = branch.first_set & other_branch.first_set

            unless overlapping.empty?
              conflicting << branch
              conflicting << other_branch
            end
          end
        end

        unless conflicting.empty?
          compiled_grammar.add_error(
            'first/first conflict, multiple branches start with the same terminals',
            rule.source_line
          )

          conflicting.each do |branch|
            labels = branch.first_set.map do |token|
              token.is_a?(Epsilon) ? 'epsilon' : token.name
            end

            compiled_grammar.add_error(
              "branch starts with: #{labels.join(', ')}",
              branch.source_line
            )
          end
        end
      end
    end

    ##
    # Adds errors for any rules containing first/follow conflicts.
    #
    # @param [LL::CompiledGrammar] compiled_grammar
    #
    def verify_first_follow(compiled_grammar)
      compiled_grammar.rules.each do |rule|
        rule.branches.each do |branch|
          has_epsilon = branch.first_set.find { |step| step.is_a?(Epsilon) }

          if has_epsilon and !branch.follow_set.empty?
            compiled_grammar.add_error(
              'first/follow conflict, branch can start with epsilon and is ' \
                'followed by (non) terminals',
              branch.source_line
            )

            compiled_grammar.add_error(
              'epsilon originates from here',
              has_epsilon.source_line
            )
          end
        end
      end
    end

    ##
    # Processes the root node of a grammar.
    #
    # @param [LL::AST::Node] node
    # @param [LL::CompiledGrammar] compiled_grammar
    #
    def on_grammar(node, compiled_grammar)
      # Create the prototypes for all rules since rules can be referenced before
      # they are defined.
      node.children.each do |child|
        if child.type == :rule
          on_rule_prototype(child, compiled_grammar)
        end
      end

      node.children.each do |child|
        process(child, compiled_grammar)
      end
    end

    ##
    # Sets the name of the parser.
    #
    # @param [LL::AST::Node] node
    # @param [LL::CompiledGrammar] compiled_grammar
    #
    def on_name(node, compiled_grammar)
      if compiled_grammar.name
        compiled_grammar.add_warning(
          "Overwriting existing parser name #{compiled_grammar.name.inspect}",
          node.source_line
        )
      end

      parts = node.children.map { |child| process(child, compiled_grammar) }

      compiled_grammar.name = parts.join('::')
    end

    ##
    # Processes the assignment of terminals.
    #
    # @see [#process]
    #
    def on_terminals(node, compiled_grammar)
      node.children.each do |child|
        name = process(child, compiled_grammar)

        if compiled_grammar.has_terminal?(name)
          compiled_grammar.add_error(
            "The terminal #{name.inspect} has already been defined",
            child.source_line
          )
        else
          compiled_grammar.add_terminal(name, child.source_line)
        end
      end
    end

    ##
    # Processes an %inner directive.
    #
    # @see [#process]
    #
    def on_inner(node, compiled_grammar)
      compiled_grammar.inner = process(node.children[0], compiled_grammar)
    end

    ##
    # Processes a %header directive.
    #
    # @see [#process]
    #
    def on_header(node, compiled_grammar)
      compiled_grammar.header = process(node.children[0], compiled_grammar)
    end

    ##
    # Processes a node containing Ruby source code.
    #
    # @see [#process]
    # @return [String]
    #
    def on_ruby(node, compiled_grammar)
      return node.children[0]
    end

    ##
    # Extracts the name from an identifier.
    #
    # @see [#process]
    # @return [String]
    #
    def on_ident(node, compiled_grammar)
      return node.children[0]
    end

    ##
    # Processes an epsilon.
    #
    # @see [#process]
    # @return [LL::Epsilon]
    #
    def on_epsilon(node, compiled_grammar)
      return Epsilon.new(node.source_line)
    end

    ##
    # Processes the assignment of a rule.
    #
    # @see [#process]
    #
    def on_rule(node, compiled_grammar)
      name = process(node.children[0], compiled_grammar)

      if compiled_grammar.has_terminal?(name)
        compiled_grammar.add_error(
          "the rule name #{name.inspect} is already used as a terminal name",
          node.source_line
        )
      end

      if compiled_grammar.has_rule_with_branches?(name)
        compiled_grammar.add_error(
          "the rule #{name.inspect} has already been defined",
          node.source_line
        )

        return
      end

      branches = node.children[1..-1].map do |child|
        process(child, compiled_grammar)
      end

      rule = compiled_grammar.lookup_rule(name)

      rule.branches.concat(branches)
    end

    ##
    # Creates a basic prototype for a rule.
    #
    # @see [#process]
    #
    def on_rule_prototype(node, compiled_grammar)
      name = process(node.children[0], compiled_grammar)

      return if compiled_grammar.has_rule?(name)

      rule = Rule.new(name, node.source_line)

      compiled_grammar.add_rule(rule)
    end

    ##
    # Processes a single rule branch.
    #
    # @see [#process]
    # @return [LL::Branch]
    #
    def on_branch(node, compiled_grammar)
      steps = process(node.children[0], compiled_grammar)

      if node.children[1]
        code = process(node.children[1], compiled_grammar)
      else
        code = nil
      end

      return Branch.new(steps, node.source_line, code)
    end

    ##
    # Processes the steps of a branch.
    #
    # @see [#process]
    # @return [Array]
    #
    def on_steps(node, compiled_grammar)
      return lookup_identifiers(node, compiled_grammar)
    end

    ##
    # Processes the "*" operator.
    #
    # @param [LL::AST::Node] node
    # @param [LL::CompiledGrammar] compiled_grammar
    # @return [LL::Operator]
    #
    def on_star(node, compiled_grammar)
      steps = lookup_identifiers(node, compiled_grammar)
      name  = "_ll_star#{node.source_line.line}#{node.source_line.column}"
      rule  = Rule.new(name, node.source_line)

      rule.add_branch(steps, node.source_line)

      rule.increment_references

      compiled_grammar.add_rule(rule)

      return Operator.new(:star, rule, node.source_line)
    end

    ##
    # Processes the "+" operator.
    #
    # @param [LL::AST::Node] node
    # @param [LL::CompiledGrammar] compiled_grammar
    # @return [LL::Operator]
    #
    def on_plus(node, compiled_grammar)
      steps = lookup_identifiers(node, compiled_grammar)
      name  = "_ll_plus#{node.source_line.line}#{node.source_line.column}"
      rule  = Rule.new(name, node.source_line)

      rule.add_branch(steps, node.source_line)

      rule.increment_references

      compiled_grammar.add_rule(rule)

      return Operator.new(:plus, rule, node.source_line)
    end

    ##
    # Processes the "?" operator.
    #
    # @param [LL::AST::Node] node
    # @param [LL::CompiledGrammar] compiled_grammar
    # @return [LL::Operator]
    #
    def on_question(node, compiled_grammar)
      steps = lookup_identifiers(node, compiled_grammar)
      name  = "_ll_question#{node.source_line.line}#{node.source_line.column}"
      rule  = Rule.new(name, node.source_line)

      rule.add_branch(steps, node.source_line)

      rule.increment_references

      compiled_grammar.add_rule(rule)

      return Operator.new(:question, rule, node.source_line)
    end

    private

    ##
    # @param [String] name
    # @param [LL::AST::Node] node
    # @param [LL::CompiledGrammar] compiled_grammar
    #
    def undefined_identifier!(name, node, compiled_grammar)
      compiled_grammar.add_error(
        "Undefined terminal or rule #{name.inspect}",
        node.source_line
      )
    end

    ##
    # @see [#process]
    # @return [Array]
    #
    def lookup_identifiers(node, compiled_grammar)
      idents = []

      node.children.each do |ident_node|
        retval = process(ident_node, compiled_grammar)

        # Literal rule/terminal names.
        if retval.is_a?(String)
          ident = compiled_grammar.lookup_identifier(retval)

          undefined_identifier!(retval, ident_node, compiled_grammar) if !ident
        # Epsilon
        else
          ident = retval
        end

        if ident
          ident.increment_references if ident.respond_to?(:increment_references)

          idents << ident
        end
      end

      return idents
    end
  end # Compiler
end # LL
