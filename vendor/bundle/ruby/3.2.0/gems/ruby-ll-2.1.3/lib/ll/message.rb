module LL
  ##
  # A warning/error generated during the compilation of a grammar.
  #
  class Message
    attr_reader :type, :message, :source_line

    ##
    # The colours to use for the various message types.
    #
    # @return [Hash]
    #
    COLORS = {
      :error   => :red,
      :warning => :yellow
    }

    ##
    # @param [Symbol] type
    # @param [String] message
    # @param [LL::SourceLine] source_line
    #
    def initialize(type, message, source_line)
      @type        = type
      @message     = message
      @source_line = source_line
    end

    ##
    # Returns a String containing details of the message, complete with ANSI
    # colour sequences.
    #
    # @return [String]
    #
    def to_s
      location = ANSI.ansi("#{determine_path}:#{line}:#{column}", :white, :bold)

      type_label = ANSI.ansi(type.to_s, COLORS[type], :bold)
      msg_line   = "#{location}:#{type_label}: #{message}"

      return "#{msg_line}\n#{source_line.source}\n#{marker}"
    end

    ##
    # @return [String]
    #
    def inspect
      return "Message(type: #{type.inspect}, message: #{message.inspect}, " \
        "file: #{determine_path.inspect}, line: #{line}, column: #{column})"
    end

    ##
    # Returns the path to the source of the message. If the path resides in the
    # current working directory (or a child directory) the path is relative,
    # otherwise it's absolute.
    #
    # @return [String]
    #
    def determine_path
      if source_line.file == SourceLine::DEFAULT_FILE
        return source_line.file
      end

      full_path = File.expand_path(source_line.file)
      pwd       = Dir.pwd

      if full_path.start_with?(pwd)
        from = Pathname.new(full_path)
        to   = Pathname.new(pwd)

        return from.relative_path_from(to).to_s
      else
        return full_path
      end
    end

    ##
    # @return [Fixnum]
    #
    def line
      return source_line.line
    end

    ##
    # @return [Fixnum]
    #
    def column
      return source_line.column
    end

    private

    ##
    # @return [String]
    #
    def marker
      padding = ' ' * (column - 1)

      return padding + ANSI.ansi('^', :magenta, :bold)
    end
  end # Message
end # LL
