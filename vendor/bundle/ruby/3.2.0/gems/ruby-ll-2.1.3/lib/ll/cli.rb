module LL
  ##
  # CLI that can be used to generate ruby-ll parsers from a grammar file.
  #
  class CLI
    ##
    # @param [Array] argv
    #
    def run(argv = ARGV)
      options, leftovers = parse(argv)

      if leftovers.empty?
        abort <<-EOF.strip
Error: you must specify a grammar input file'

#{parser}
EOF
      end

      input = File.expand_path(leftovers[0])

      unless options[:output]
        options[:output] = output_from_input(input)
      end

      generate(input, options)
    end

    ##
    # @param [String] input
    # @return [String]
    #
    def output_from_input(input)
      input_ext = File.extname(input)

      return input.gsub(/#{Regexp.compile(input_ext)}$/, '.rb')
    end

    ##
    # @param [String] input
    # @param [Hash] options
    #
    def generate(input, options)
      raw_grammar    = File.read(input)
      parser         = Parser.new(raw_grammar, input)
      gcompiler      = GrammarCompiler.new
      codegen        = CodeGenerator.new
      configcompiler = ConfigurationCompiler.new

      ast      = parser.parse
      cgrammar = gcompiler.compile(ast)

      cgrammar.display_messages

      if cgrammar.valid?
        config = configcompiler.generate(cgrammar)
        output = codegen.generate(config, options[:requires])

        File.open(options[:output], 'w') do |file|
          file.write(output)
        end
      else
        exit 1
      end
    end

    ##
    # @param [Array] argv
    # @return [Array]
    #
    def parse(argv)
      options = {
        :requires => true,
        :output   => nil
      }

      parser = OptionParser.new do |opt|
        opt.summary_indent = '  '

        opt.banner = <<-EOF.strip
Usage: ruby-ll [INPUT-GRAMMAR] [OPTIONS]

About:

  Generates a Ruby LL(1) parser from a ruby-ll compatible grammar file.

Examples:

  ruby-ll lib/ll/parser.rll                   # output goes to lib/ll/parser.rl
  ruby-ll lib/ll/parser.rll -o /tmp/parser.rb # output goes to /tmp/parser.rb
        EOF

        opt.separator "\nOptions:\n\n"

        opt.on '-h', '--help', 'Shows this help message' do
          abort parser.to_s
        end

        opt.on '--no-requires', 'Disables adding of require calls' do
          options[:requires] = false
        end

        opt.on '-o [PATH]', '--output [PATH]', 'Writes output to PATH' do |val|
          options[:output] = val
        end

        opt.on '-v', '--version', 'Shows the current version' do
          puts "ruby-ll #{VERSION} on #{RUBY_DESCRIPTION}"
          exit
        end
      end

      leftovers = parser.parse(argv)

      return options, leftovers
    end
  end # CLI
end # LL
