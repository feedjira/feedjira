module LL
  ##
  # The Branch class contains information of a single rule branch such as the
  # steps and the associated callback code.
  #
  class Branch
    attr_reader :steps, :source_line, :ruby_code

    ##
    # @param [Array] steps
    # @param [LL::SourceLine] source_line
    # @param [String] ruby_code
    #
    def initialize(steps, source_line, ruby_code = nil)
      @steps       = steps
      @source_line = source_line
      @ruby_code   = ruby_code
    end

    ##
    # Returns the FIRST() set of this branch.
    #
    # @return [Array<LL::Terminal>]
    #
    def first_set
      first = steps[0]

      if first.is_a?(Rule)
        return first.first_set
      elsif first
        return [first]
      else
        return []
      end
    end

    ##
    # Returns the FOLLOW() set of this branch.
    #
    # @return [Array<LL::Terminal>]
    #
    def follow_set
      follow = steps[1]

      if follow.is_a?(Rule)
        set = follow.first_set
      elsif follow
        set = [follow]
      else
        set = []
      end

      return set
    end

    ##
    # @return [String]
    #
    def inspect
      return "Branch(steps: #{steps.inspect}, ruby_code: #{ruby_code.inspect})"
    end
  end # Branch
end # LL
