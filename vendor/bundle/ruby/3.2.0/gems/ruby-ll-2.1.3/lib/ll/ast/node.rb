module LL
  module AST
    ##
    # Class containing details of a single node in an LL grammar AST.
    #
    class Node < ::AST::Node
      ##
      # @return [LL::SourceLine]
      #
      attr_reader :source_line
    end # Node
  end # AST
end # LL
