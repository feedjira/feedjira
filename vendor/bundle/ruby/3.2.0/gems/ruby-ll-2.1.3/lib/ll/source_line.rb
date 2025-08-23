module LL
  ##
  # Class containing data of a lexer token's source line source as the raw data,
  # column, line number, etc.
  #
  class SourceLine
    attr_reader :file, :data, :line, :column

    ##
    # @return [String]
    #
    DEFAULT_FILE = '(ruby)'

    ##
    # @param [String] data
    # @param [Fixnum] line
    # @param [Fixnum] column
    # @param [String] file
    #
    def initialize(data, line = 1, column = 1, file = DEFAULT_FILE)
      @file   = file
      @data   = data
      @line   = line
      @column = column
    end

    ##
    # @return [String]
    #
    def source
      return data.lines.to_a[line - 1].chomp
    end

    ##
    # @return [TrueClass|FalseClass]
    #
    def ==(other)
      return false unless other.class == self.class

      return file == other.file &&
        data == other.data &&
        line == other.line &&
        column == other.column
    end
  end # SourceLine
end # LL
