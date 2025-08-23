
# line 1 "lib/ll/lexer.rl"

# line 3 "lib/ll/lexer.rl"
module LL
  ##
  # Ragel lexer for LL grammar files.
  #
  class Lexer
    
# line 9 "lib/ll/lexer.rb"
class << self
	attr_accessor :_ll_lexer_trans_keys
	private :_ll_lexer_trans_keys, :_ll_lexer_trans_keys=
end
self._ll_lexer_trans_keys = [
	0, 0, 104, 116, 101, 101, 
	97, 97, 100, 100, 101, 
	101, 114, 114, 110, 110, 
	110, 110, 101, 101, 114, 114, 
	97, 97, 109, 109, 101, 
	101, 101, 101, 114, 114, 
	109, 109, 105, 105, 110, 110, 
	97, 97, 108, 108, 115, 
	115, 0, 127, 0, 127, 
	10, 10, 10, 125, 0
]

class << self
	attr_accessor :_ll_lexer_key_spans
	private :_ll_lexer_key_spans, :_ll_lexer_key_spans=
end
self._ll_lexer_key_spans = [
	0, 13, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 128, 128, 
	1, 116
]

class << self
	attr_accessor :_ll_lexer_index_offsets
	private :_ll_lexer_index_offsets, :_ll_lexer_index_offsets=
end
self._ll_lexer_index_offsets = [
	0, 0, 14, 16, 18, 20, 22, 24, 
	26, 28, 30, 32, 34, 36, 38, 40, 
	42, 44, 46, 48, 50, 52, 54, 183, 
	312, 314
]

class << self
	attr_accessor :_ll_lexer_indicies
	private :_ll_lexer_indicies, :_ll_lexer_indicies=
end
self._ll_lexer_indicies = [
	0, 2, 1, 1, 1, 1, 3, 1, 
	1, 1, 1, 1, 4, 1, 5, 1, 
	6, 1, 7, 1, 8, 1, 9, 1, 
	10, 1, 11, 1, 12, 1, 13, 1, 
	14, 1, 15, 1, 16, 1, 17, 1, 
	18, 1, 19, 1, 20, 1, 21, 1, 
	22, 1, 23, 1, 24, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 26, 
	27, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 26, 1, 
	1, 28, 1, 29, 1, 1, 30, 31, 
	32, 33, 1, 1, 1, 1, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	34, 35, 1, 36, 1, 37, 1, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 1, 1, 1, 1, 38, 1, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 39, 40, 1, 1, 1, 25, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 41, 41, 41, 41, 41, 41, 41, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 41, 41, 41, 41, 25, 41, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 25, 25, 25, 25, 25, 25, 
	25, 25, 41, 41, 41, 41, 41, 25, 
	42, 28, 44, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 45, 43, 46, 43, 0
]

class << self
	attr_accessor :_ll_lexer_trans_targs
	private :_ll_lexer_trans_targs, :_ll_lexer_trans_targs=
end
self._ll_lexer_trans_targs = [
	2, 0, 7, 11, 14, 3, 4, 5, 
	6, 22, 8, 9, 10, 22, 12, 13, 
	22, 15, 16, 17, 18, 19, 20, 21, 
	22, 23, 22, 22, 24, 1, 22, 22, 
	22, 22, 22, 22, 22, 22, 23, 22, 
	22, 22, 22, 25, 25, 25, 25
]

class << self
	attr_accessor :_ll_lexer_trans_actions
	private :_ll_lexer_trans_actions, :_ll_lexer_trans_actions=
end
self._ll_lexer_trans_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 2, 0, 0, 
	3, 0, 0, 0, 0, 0, 0, 0, 
	4, 7, 8, 9, 0, 0, 10, 11, 
	12, 13, 14, 15, 16, 17, 18, 19, 
	20, 21, 22, 23, 24, 25, 26
]

class << self
	attr_accessor :_ll_lexer_to_state_actions
	private :_ll_lexer_to_state_actions, :_ll_lexer_to_state_actions=
end
self._ll_lexer_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 5, 0, 
	0, 5
]

class << self
	attr_accessor :_ll_lexer_from_state_actions
	private :_ll_lexer_from_state_actions, :_ll_lexer_from_state_actions=
end
self._ll_lexer_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 6, 0, 
	0, 6
]

class << self
	attr_accessor :_ll_lexer_eof_trans
	private :_ll_lexer_eof_trans, :_ll_lexer_eof_trans=
end
self._ll_lexer_eof_trans = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 42, 
	43, 0
]

class << self
	attr_accessor :ll_lexer_start
end
self.ll_lexer_start = 22;
class << self
	attr_accessor :ll_lexer_first_final
end
self.ll_lexer_first_final = 22;
class << self
	attr_accessor :ll_lexer_error
end
self.ll_lexer_error = 0;

class << self
	attr_accessor :ll_lexer_en_ruby_body
end
self.ll_lexer_en_ruby_body = 25;
class << self
	attr_accessor :ll_lexer_en_main
end
self.ll_lexer_en_main = 22;


# line 9 "lib/ll/lexer.rl"

    # % fix highlight

    ##
    # @param [String] data The data to lex.
    # @param [String] file The name of the input file.
    #
    def initialize(data, file = SourceLine::DEFAULT_FILE)
      @data = data
      @file = file

      reset
    end

    ##
    # Gathers all the tokens for the input and returns them as an Array.
    #
    # @see [#advance]
    # @return [Array]
    #
    def lex
      tokens = []

      advance do |token|
        tokens << token
      end

      return tokens
    end

    ##
    # Resets the internal state of the lexer.
    #
    def reset
      @block  = nil
      @line   = 1
      @column = 1
    end

    ##
    # Advances through the input and generates the corresponding tokens. Each
    # token is yielded to the supplied block.
    #
    # @see [#add_token]
    #
    def advance(&block)
      @block = block

      data = @data # saves ivar lookups while lexing.
      ts   = nil
      te   = nil
      cs   = self.class.ll_lexer_start
      act  = 0
      eof  = @data.bytesize
      p    = 0
      pe   = eof

      mark        = 0
      brace_count = 0
      start_line  = 0

      _ll_lexer_eof_trans          = self.class.send(:_ll_lexer_eof_trans)
      _ll_lexer_from_state_actions = self.class.send(:_ll_lexer_from_state_actions)
      _ll_lexer_index_offsets      = self.class.send(:_ll_lexer_index_offsets)
      _ll_lexer_indicies           = self.class.send(:_ll_lexer_indicies)
      _ll_lexer_key_spans          = self.class.send(:_ll_lexer_key_spans)
      _ll_lexer_to_state_actions   = self.class.send(:_ll_lexer_to_state_actions)
      _ll_lexer_trans_actions      = self.class.send(:_ll_lexer_trans_actions)
      _ll_lexer_trans_keys         = self.class.send(:_ll_lexer_trans_keys)
      _ll_lexer_trans_targs        = self.class.send(:_ll_lexer_trans_targs)

      
# line 263 "lib/ll/lexer.rb"
begin
	testEof = false
	_slen, _trans, _keys, _inds, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	case _ll_lexer_from_state_actions[cs] 
	when 6 then
# line 1 "NONE"
		begin
ts = p
		end
# line 291 "lib/ll/lexer.rb"
	end
	_keys = cs << 1
	_inds = _ll_lexer_index_offsets[cs]
	_slen = _ll_lexer_key_spans[cs]
	_wide = ( (data.getbyte(p) || 0))
	_trans = if (   _slen > 0 && 
			_ll_lexer_trans_keys[_keys] <= _wide && 
			_wide <= _ll_lexer_trans_keys[_keys + 1] 
		    ) then
			_ll_lexer_indicies[ _inds + _wide - _ll_lexer_trans_keys[_keys] ] 
		 else 
			_ll_lexer_indicies[ _inds + _slen ]
		 end
	end
	if _goto_level <= _eof_trans
	cs = _ll_lexer_trans_targs[_trans]
	if _ll_lexer_trans_actions[_trans] != 0
	case _ll_lexer_trans_actions[_trans]
	when 25 then
# line 188 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  brace_count += 1  end
		end
	when 26 then
# line 190 "lib/ll/lexer.rl"
		begin
te = p+1
 begin 
          if brace_count == 1
            emit(:T_RUBY, mark, ts, start_line)

            mark        = 0
            brace_count = 0
            start_line  = 0

            advance_column

            cs = 22;
          else
            brace_count -= 1
          end
         end
		end
	when 23 then
# line 206 "lib/ll/lexer.rl"
		begin
te = p+1
		end
	when 3 then
# line 215 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_NAME, ts, te)  end
		end
	when 4 then
# line 216 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_TERMINALS, ts, te)  end
		end
	when 2 then
# line 217 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_INNER, ts, te)  end
		end
	when 1 then
# line 218 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_HEADER, ts, te)  end
		end
	when 16 then
# line 220 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_EQUALS, ts, te)  end
		end
	when 14 then
# line 221 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_COLON, ts, te)  end
		end
	when 15 then
# line 222 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_SEMICOLON, ts, te)  end
		end
	when 20 then
# line 223 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_PIPE, ts, te)  end
		end
	when 13 then
# line 225 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_PLUS, ts, te)  end
		end
	when 12 then
# line 226 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_STAR, ts, te)  end
		end
	when 17 then
# line 227 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_QUESTION, ts, te)  end
		end
	when 10 then
# line 228 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_LPAREN, ts, te)  end
		end
	when 11 then
# line 229 "lib/ll/lexer.rl"
		begin
te = p+1
 begin  emit(:T_RPAREN, ts, te)  end
		end
	when 19 then
# line 231 "lib/ll/lexer.rl"
		begin
te = p+1
 begin 
          mark        = ts + 1
          brace_count = 1
          start_line  = @line

          advance_column

          cs = 25;
         end
		end
	when 22 then
# line 213 "lib/ll/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 21 then
# line 1 "NONE"
		begin
	case act
	when 16 then
	begin begin p = ((te))-1; end
 emit(:T_EPSILON, ts, te) end
	when 23 then
	begin begin p = ((te))-1; end

        emit(:T_IDENT, ts, te)
      end
end 
			end
	when 24 then
# line 148 "lib/ll/lexer.rl"
		begin

        advance_line

        @column = 1
      		end
# line 186 "lib/ll/lexer.rl"
		begin
te = p+1
		end
	when 9 then
# line 148 "lib/ll/lexer.rl"
		begin

        advance_line

        @column = 1
      		end
# line 210 "lib/ll/lexer.rl"
		begin
te = p+1
		end
	when 8 then
# line 154 "lib/ll/lexer.rl"
		begin

        advance_column
      		end
# line 211 "lib/ll/lexer.rl"
		begin
te = p+1
		end
	when 18 then
# line 1 "NONE"
		begin
te = p+1
		end
# line 224 "lib/ll/lexer.rl"
		begin
act = 16;		end
	when 7 then
# line 1 "NONE"
		begin
te = p+1
		end
# line 168 "lib/ll/lexer.rl"
		begin
act = 23;		end
# line 502 "lib/ll/lexer.rb"
	end
	end
	end
	if _goto_level <= _again
	case _ll_lexer_to_state_actions[cs] 
	when 5 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 512 "lib/ll/lexer.rb"
	end

	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _ll_lexer_eof_trans[cs] > 0
		_trans = _ll_lexer_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
	end

	end
	if _goto_level <= _out
		break
	end
end
	end

# line 81 "lib/ll/lexer.rl"

      # % fix highlight
    ensure
      reset
    end

    private

    ##
    # Emits a token of which the value is based on the supplied start/stop
    # position.
    #
    # @param [Symbol] type The token type.
    # @param [Fixnum] start
    # @param [Fixnum] stop
    # @param [Fixnum] line
    #
    # @see [#text]
    # @see [#add_token]
    #
    def emit(type, start, stop, line = @line)
      value = slice_input(start, stop)

      add_token(type, value, line)
    end

    ##
    # Returns the text between the specified start and stop position.
    #
    # @param [Fixnum] start
    # @param [Fixnum] stop
    # @return [String]
    #
    def slice_input(start, stop)
      return @data.byteslice(start, stop - start)
    end

    ##
    # Yields a new token to the supplied block.
    #
    # @param [Symbol] type The token type.
    # @param [String] value The token value.
    # @param [Fixnum] line
    #
    # @yieldparam [LL::Token] token
    #
    def add_token(type, value, line = @line)
      source_line = SourceLine.new(@data, line, @column, @file)
      @column    += value.length

      @block.call(Token.new(type, value, source_line))
    end

    def advance_line
      @line += 1
    end

    def advance_column
      @column += 1
    end

    
# line 243 "lib/ll/lexer.rl"

  end # Lexer
end # Oga
