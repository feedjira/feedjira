module LL
  ##
  # Parser driver for generated parsers.
  #
  class Driver
    ##
    # @param [Fixnum] stack_type
    # @param [Fixnum] stack_value
    # @param [Symbol] token_type
    # @param [Mixed] token_value
    #
    def parser_error(stack_type, stack_value, token_type, token_value)
      message = parser_error_message(stack_type, stack_value, token_type)

      raise ParserError, message
    end

    ##
    # @param [Fixnum] stack_type
    # @param [Fixnum] stack_value
    # @param [Symbol] token_type
    # @return [String]
    #
    def parser_error_message(stack_type, stack_value, token_type)
      case id_to_type(stack_type)
      when :rule
        message = "Unexpected #{token_type} for rule #{stack_value}"
      when :terminal
        expected = id_to_terminal(stack_value)
        message  = "Unexpected #{token_type}, expected #{expected} instead"
      when :eof
        message = "Received #{token_type} but there's nothing left to parse"
      when :star
        message = %Q{Unexpected #{token_type} for a "*" operator}
      when :plus
        message = %Q{Unexpected #{token_type} for a "+" operator}
      when :question
        message = %Q{Unexpected #{token_type} for a "?" operator}
      end

      return message
    end

    ##
    # Returns the Symbol that belongs to the stack type number.
    #
    # @example
    #  id_to_type(1) # => :terminal
    #
    # @param [Fixnum] id
    # @return [Symbol]
    #
    def id_to_type(id)
      return ConfigurationCompiler::TYPES.invert[id]
    end

    ##
    # Returns the Symbol of the terminal index.
    #
    # @param [Fixnum] id
    # @return [Symbol]
    #
    def id_to_terminal(id)
      return self.class::CONFIG.terminals[id]
    end
  end # Driver
end # LL
