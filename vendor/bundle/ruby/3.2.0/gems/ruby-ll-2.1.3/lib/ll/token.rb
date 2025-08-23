module LL
  ##
  # A Token contains the data of a single lexer token.
  #
  class Token
    attr_reader :type, :value, :source_line

    ##
    # @param [Symbol] type
    # @param [String] value
    # @param [LL::SourceLine] source_line
    #
    def initialize(type, value, source_line)
      @type        = type
      @value       = value
      @source_line = source_line
    end

    ##
    # @return [TrueClass|FalseClass]
    #
    def ==(other)
      return false unless other.class == self.class

      return type == other.type &&
        value == other.value &&
        source_line == other.source_line
    end
  end # Token
end # LL
