module LL
  ##
  # Class for storing the compiled state/lookup/action tables and the likes.
  #
  class CompiledConfiguration
    attr_reader :name, :namespace, :inner, :header, :terminals, :rules, :table,
      :actions, :action_bodies

    ##
    # @param [Hash] options
    #
    # @option options [String] :name
    # @option options [Array] :namespace
    # @option options [String] :inner
    # @option options [String] :header
    # @option options [Array] :terminals
    # @option options [Array] :rules
    # @option options [Array] :table
    # @option options [Array] :actions
    # @option options [Hash] :action_bodies
    #
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value) if respond_to?(key)
      end

      @namespace     ||= []
      @terminals     ||= []
      @rules         ||= []
      @table         ||= []
      @actions       ||= []
      @action_bodies ||= {}
    end
  end # CompiledConfiguration
end # LL
