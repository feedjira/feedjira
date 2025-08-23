module LL
  ##
  # Class containing details of a single rule in a grammar.
  #
  class Rule
    attr_reader :name, :branches, :source_line, :references

    ##
    # @param [String] name
    # @param [LL::SourceLine] source_line
    #
    def initialize(name, source_line)
      @name        = name
      @branches    = []
      @source_line = source_line
      @references  = 0
    end

    ##
    # @see [LL::Branch#initialize]
    #
    def add_branch(steps, source_line, ruby_code = nil)
      branches << Branch.new(steps, source_line, ruby_code)
    end

    def increment_references
      @references += 1
    end

    ##
    # Returns an Array containing the terminals that make up the FIRST() set of
    # this rule.
    #
    # @return [Array<LL::Terminal>]
    #
    def first_set
      terminals = []

      branches.each do |branch|
        terminals += branch.first_set
      end

      return terminals
    end

    ##
    # @return [String]
    #
    def inspect
      return "Rule(name: #{name.inspect}, branches: #{branches.inspect})"
    end
  end # Rule
end # LL
