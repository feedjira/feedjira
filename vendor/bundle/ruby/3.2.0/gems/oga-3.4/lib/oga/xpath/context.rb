module Oga
  module XPath
    # Class used as the context for compiled XPath Procs.
    #
    # The binding of this class is used for the binding of Procs compiled by
    # {Compiler}. Not using a specific binding would result in the procs
    # using the binding of {Compiler#compile}, which could lead to race
    # conditions.
    class Context
      # @param [String] string
      # @return [Proc]
      def evaluate(string)
        binding.eval(string)
      end
    end # Context
  end # XPath
end # Oga
