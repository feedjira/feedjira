module LL
  ##
  # Class for operators such as + and *.
  #
  class Operator
    attr_reader :type, :receiver, :source_line

    ##
    # @param [Symbol] type
    # @param [LL::Rule] receiver
    # @param [LL::SourceLine] source_line
    #
    def initialize(type, receiver, source_line)
      @type        = type
      @receiver    = receiver
      @source_line = source_line
    end

    ##
    # @return [String]
    #
    def inspect
      return "Operator(type: #{type.inspect}, receiver: #{receiver.inspect})"
    end
  end # Operator
end # LL
