module LL
  ##
  # Class containing details of a single terminal in a grammar.
  #
  class Terminal
    attr_reader :name, :source_line, :references

    ##
    # @param [String] name
    # @param [LL::SourceLine] source_line
    #
    def initialize(name, source_line)
      @name        = name
      @source_line = source_line
      @references  = 0
    end

    def increment_references
      @references += 1
    end

    ##
    # @return [String]
    #
    def inspect
      return "Terminal(name: #{name.inspect})"
    end
  end # Terminal
end # LL
