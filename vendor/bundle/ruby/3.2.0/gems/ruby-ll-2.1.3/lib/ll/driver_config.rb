module LL
  ##
  # Class containing C/Java data for a Driver class.
  #
  class DriverConfig
    attr_reader :terminals, :rules, :table, :actions

    ##
    # @param [Array] array
    #
    def terminals=(array)
      self.terminals_native = @terminals = array
    end

    ##
    # @param [Array] array
    #
    def rules=(array)
      self.rules_native = @rules = array
    end

    ##
    # @param [Array] array
    #
    def table=(array)
      self.table_native = @table = array
    end

    ##
    # @param [Array] array
    #
    def actions=(array)
      self.actions_native = @actions = array
    end
  end # DriverConfig
end # LL
