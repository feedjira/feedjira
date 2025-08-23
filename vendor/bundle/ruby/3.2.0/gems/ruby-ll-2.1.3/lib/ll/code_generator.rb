module LL
  ##
  # The CodeGenerator class takes a {LL::CompiledConfiguration} instance and
  # turns it into a block of Ruby source code that can be used as an actual
  # LL(1) parser.
  #
  class CodeGenerator
    ##
    # The ERB template to use for code generation.
    #
    # @return [String]
    #
    TEMPLATE = File.expand_path('../driver_template.erb', __FILE__)

    ##
    # @param [LL::CompiledConfiguration] config
    # @param [TrueClass|FalseClass] add_requires
    # @return [String]
    #
    def generate(config, add_requires = true)
      context = ERBContext.new(
        :config       => config,
        :add_requires => add_requires
      )

      template = File.read(TEMPLATE)
      erb      = ERB.new(template, trim_mode: '-').result(context.get_binding)

      return erb
    end
  end # CodeGenerator
end # LL
