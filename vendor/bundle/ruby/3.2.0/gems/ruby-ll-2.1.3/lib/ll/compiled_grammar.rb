module LL
  ##
  # The CompiledGrammar class contains compilation results such as the parser
  # name, the rules of the grammar, the terminals, etc.
  #
  class CompiledGrammar
    attr_accessor :name, :inner, :header

    attr_reader :warnings, :errors

    def initialize
      @warnings  = []
      @errors    = []
      @terminals = {}
      @rules     = {}
      @inner     = nil
      @header    = nil
    end

    ##
    # @param [String] message
    # @param [LL::SourceLine] source_line
    #
    def add_error(message, source_line)
      @errors << Message.new(:error, message, source_line)
    end

    ##
    # @param [String] message
    # @param [LL::SourceLine] source_line
    #
    def add_warning(message, source_line)
      @warnings << Message.new(:warning, message, source_line)
    end

    ##
    # @param [String] name
    # @return [TrueClass|FalseClass]
    #
    def has_terminal?(name)
      return @terminals.key?(name)
    end

    ##
    # @param [String] name
    # @param [LL::SourceLine] source_line
    # @return [LL::Terminal]
    #
    def add_terminal(name, source_line)
      return @terminals[name] = Terminal.new(name, source_line)
    end

    ##
    # Returns true if a rule for the given name has already been assigned.
    #
    # @param [String] name
    # @return [TrueClass|FalseClass]
    #
    def has_rule?(name)
      return @rules.key?(name)
    end

    ##
    # Returns true if a rule already exists for a given name _and_ has at least
    # 1 branch.
    #
    # @see [#has_rule?]
    #
    def has_rule_with_branches?(name)
      return has_rule?(name) && !@rules[name].branches.empty?
    end

    ##
    # @param [LL::Rule] rule
    # @return [LL::Rule]
    #
    def add_rule(rule)
      return @rules[rule.name] = rule
    end

    ##
    # @param [String] name
    # @return [LL::Rule]
    #
    def lookup_rule(name)
      return @rules[name]
    end

    ##
    # Looks up an identifier from the list of terminals and/or rules. Rules take
    # precedence over terminals.
    #
    # If no rule/terminal could be found nil is returned instead.
    #
    # @param [String] name
    # @return [LL::Rule|LL::Terminal|NilClass]
    #
    def lookup_identifier(name)
      if has_rule?(name)
        ident = lookup_rule(name)
      elsif has_terminal?(name)
        ident = @terminals[name]
      else
        ident = nil
      end

      return ident
    end

    ##
    # @return [Array]
    #
    def rules
      return @rules.values
    end

    ##
    # @return [Hash]
    #
    def rule_indices
      return rules.each_with_index.each_with_object({}) do |(rule, idx), h|
        h[rule] = idx
      end
    end

    ##
    # @return [Array]
    #
    def terminals
      return @terminals.values
    end

    ##
    # @return [Hash]
    #
    def terminal_indices
      return terminals.each_with_index.each_with_object({}) do |(term, idx), h|
        h[term] = idx
      end
    end

    ##
    # @return [TrueClass|FalseClass]
    #
    def valid?
      return @errors.empty?
    end

    ##
    # Displays all warnings and errors.
    #
    def display_messages
      [:errors, :warnings].each do |type|
        send(type).each do |msg|
          output.puts(msg.to_s)
        end
      end
    end

    ##
    # @return [IO]
    #
    def output
      return STDERR
    end
  end # CompiledGrammar
end # LL
