module LL
  ##
  # A context for a single ERB template, used for storing variables and
  # retrieving the binding for a template.
  #
  class ERBContext
    ##
    # @param [Hash] variables
    #
    def initialize(variables = {})
      variables.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    ##
    # @return [Binding]
    #
    def get_binding
      return binding
    end
  end # ERBContext
end # LL
