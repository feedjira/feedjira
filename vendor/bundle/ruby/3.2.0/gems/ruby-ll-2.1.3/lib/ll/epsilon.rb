module LL
  ##
  # Class used for indicating an epsilon in a grammar. Epsilon objects are
  # primarily used to break out of recursion.
  #
  class Epsilon
    attr_reader :source_line

    ##
    # @param [LL::SourceLine] source_line
    #
    def initialize(source_line)
      @source_line = source_line
    end

    ##
    # @return [String]
    #
    def inspect
      return 'Epsilon()'
    end
  end # Epsilon
end # LL
