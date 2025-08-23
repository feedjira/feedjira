module LL
  ##
  # Compiles an instance of {LL::CompiledConfiguration} which is used by
  # {LL::CodeGenerator} to actually generate Ruby source code.
  #
  class ConfigurationCompiler
    ##
    # @return [Hash]
    #
    TYPES = {
      :eof                => -1,
      :rule               => 0,
      :terminal           => 1,
      :epsilon            => 2,
      :action             => 3,
      :star               => 4,
      :plus               => 5,
      :add_value_stack    => 6,
      :append_value_stack => 7,
      :question           => 8
    }.freeze

    ##
    # Operators which don't require a value stack.
    #
    # @return [Array]
    #
    SKIP_VALUE_STACK = [:question]

    ##
    # @return [String]
    #
    DEFAULT_RUBY_CODE = 'val'.freeze

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [LL::CompiledConfiguration]
    #
    def generate(grammar)
      return CompiledConfiguration.new(
        :name          => generate_name(grammar),
        :namespace     => generate_namespace(grammar),
        :inner         => grammar.inner,
        :header        => grammar.header,
        :terminals     => generate_terminals(grammar),
        :actions       => generate_actions(grammar),
        :action_bodies => generate_action_bodies(grammar),
        :rules         => generate_rules(grammar),
        :table         => generate_table(grammar)
      )
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [String]
    #
    def generate_name(grammar)
      return grammar.name.split('::').last
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_namespace(grammar)
      parts = grammar.name.split('::')

      return parts.length > 1 ? parts[0..-2] : []
    end

    ##
    # Returns an Array containing all the terminal names as symbols. The first
    # terminal is always `:$EOF` to ensure the array has the same amount of rows
    # as there are columns in the `table` array.
    #
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_terminals(grammar)
      terminals = [:$EOF]

      grammar.terminals.each do |term|
        terminals << term.name.to_sym
      end

      return terminals
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_actions(grammar)
      actions = []
      index   = 0

      grammar.rules.each do |rule|
        rule.branches.each do |branch|
          args = branch.steps.reject { |step| step.is_a?(Epsilon) }.length

          actions << [:"_rule_#{index}", args]

          index += 1
        end
      end

      return actions
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [Hash]
    #
    def generate_action_bodies(grammar)
      bodies = {}
      index  = 0

      grammar.rules.each do |rule|
        rule.branches.each do |branch|
          if branch.ruby_code
            code = branch.ruby_code

          # If a branch only contains a single, non-epsilon step we can just
          # return that value as-is. This makes parsing code a little bit
          # easier.
          elsif !branch.ruby_code and branch.steps.length == 1 \
          and !branch.steps[0].is_a?(Epsilon)
            code = 'val[0]'

          else
            code = DEFAULT_RUBY_CODE
          end

          bodies[:"_rule_#{index}"] = code

          index += 1
        end
      end

      return bodies
    end

    ##
    # Builds the rules table of the parser. Each row is built in reverse order.
    #
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_rules(grammar)
      rules        = []
      action_index = 0
      rule_indices = grammar.rule_indices
      term_indices = grammar.terminal_indices

      grammar.rules.each_with_index do |rule, rule_index|
        rule.branches.each do |branch|
          row = [TYPES[:action], action_index]

          action_index += 1

          branch.steps.reverse_each do |step|
            if step.is_a?(Terminal)
              row << TYPES[:terminal]
              row << term_indices[step] + 1

            elsif step.is_a?(Rule)
              row << TYPES[:rule]
              row << rule_indices[step]

            elsif step.is_a?(Epsilon)
              row << TYPES[:epsilon]
              row << 0

            elsif step.is_a?(Operator)
              row << TYPES[step.type]
              row << rule_indices[step.receiver]

              unless SKIP_VALUE_STACK.include?(step.type)
                row << TYPES[:add_value_stack]
                row << 0
              end
            end
          end

          rules << row
        end
      end

      return rules
    end

    ##
    # Generates the table array for the parser. This array has the following
    # structure:
    #
    #     [
    #       [EOF, TERMINAL 1, TERMINAL 2, TERMINAL 3, ...]
    #     ]
    #
    # EOF is always the first column and is used when running out of input while
    # processing a rule.
    #
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_table(grammar)
      branch_index = 0
      term_indices = grammar.terminal_indices
      columns      = grammar.terminals.length + 1

      table = Array.new(grammar.rules.length) do
        Array.new(columns, -1)
      end

      grammar.rules.each_with_index do |rule, rule_index|
        rule.branches.each do |branch|
          branch.first_set.each do |step|
            # For terminals we'll base the column index on the terminal index.
            if step.is_a?(Terminal)
              terminal_index = term_indices[step]

              table[rule_index][terminal_index + 1] = branch_index

            # For the rest (= epsilon) we'll update all columns that haven't
            # been updated yet.
            else
              table[rule_index].each_with_index do |col, col_index|
                table[rule_index][col_index] = branch_index if col == -1
              end
            end
          end

          branch_index += 1
        end
      end

      return table
    end
  end # ConfigurationCompiler
end # LL
