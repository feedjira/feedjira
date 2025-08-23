
# line 1 "lib/oga/css/lexer.rl"

# line 3 "lib/oga/css/lexer.rl"
module Oga
  module CSS
    # Lexer for turning CSS expressions into a sequence of tokens. Tokens are
    # returned as arrays with every array having two values:
    #
    # 1. The token type as a Symbol
    # 2. The token value, or nil if there is no value.
    #
    # ## Thread Safety
    #
    # Similar to the XPath lexer this lexer keeps track of an internal state. As
    # a result it's not safe to share the same instance of this lexer between
    # multiple threads. However, no global state is used so you can use separate
    # instances in threads just fine.
    #
    # @api private
    class Lexer
      
# line 24 "lib/oga/css/lexer.rb"
class << self
	attr_accessor :_css_lexer_trans_keys
	private :_css_lexer_trans_keys, :_css_lexer_trans_keys=
end
self._css_lexer_trans_keys = [
	0, 0, 46, 46, 46, 46, 
	43, 57, 118, 118, 101, 
	101, 110, 110, 100, 100, 
	100, 100, 46, 46, 34, 34, 
	61, 61, 39, 39, 61, 
	61, 61, 61, 61, 61, 
	0, 127, 0, 127, 0, 127, 
	9, 126, 9, 32, 9, 
	32, 9, 32, 9, 32, 
	0, 0, 0, 0, 0, 0, 
	0, 127, 0, 127, 0, 
	127, 9, 32, 0, 0, 
	48, 57, 43, 57, 0, 0, 
	0, 0, 0, 127, 0, 
	127, 0, 127, 9, 32, 
	61, 61, 0
]

class << self
	attr_accessor :_css_lexer_key_spans
	private :_css_lexer_key_spans, :_css_lexer_key_spans=
end
self._css_lexer_key_spans = [
	0, 1, 1, 15, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	128, 128, 128, 118, 24, 24, 24, 24, 
	0, 0, 0, 128, 128, 128, 24, 0, 
	10, 15, 0, 0, 128, 128, 128, 24, 
	1
]

class << self
	attr_accessor :_css_lexer_index_offsets
	private :_css_lexer_index_offsets, :_css_lexer_index_offsets=
end
self._css_lexer_index_offsets = [
	0, 0, 2, 4, 20, 22, 24, 26, 
	28, 30, 32, 34, 36, 38, 40, 42, 
	44, 173, 302, 431, 550, 575, 600, 625, 
	650, 651, 652, 653, 782, 911, 1040, 1065, 
	1066, 1077, 1093, 1094, 1095, 1224, 1353, 1482, 
	1507
]

class << self
	attr_accessor :_css_lexer_indicies
	private :_css_lexer_indicies, :_css_lexer_indicies=
end
self._css_lexer_indicies = [
	1, 0, 3, 2, 5, 4, 5, 4, 
	4, 6, 6, 6, 6, 6, 6, 6, 
	6, 6, 6, 4, 7, 8, 9, 8, 
	10, 8, 11, 8, 12, 8, 14, 13, 
	16, 15, 17, 8, 16, 18, 19, 8, 
	20, 8, 21, 8, 23, 23, 23, 23, 
	23, 23, 23, 23, 23, 24, 23, 23, 
	23, 23, 23, 23, 23, 23, 23, 23, 
	23, 23, 23, 23, 23, 23, 23, 23, 
	23, 23, 23, 23, 24, 23, 23, 25, 
	23, 23, 23, 23, 26, 23, 27, 28, 
	29, 23, 30, 23, 23, 23, 23, 23, 
	23, 23, 23, 23, 23, 23, 31, 23, 
	23, 23, 32, 23, 23, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 33, 
	23, 23, 23, 22, 23, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 23, 
	34, 23, 35, 23, 22, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 22, 36, 36, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 36, 
	36, 36, 36, 36, 36, 36, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	36, 37, 36, 36, 22, 36, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	22, 22, 22, 22, 22, 22, 22, 22, 
	36, 36, 36, 36, 36, 22, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 39, 38, 38, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	38, 38, 38, 38, 38, 38, 38, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 38, 40, 38, 38, 39, 38, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 39, 39, 39, 39, 39, 39, 39, 
	39, 38, 38, 38, 38, 38, 39, 24, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 24, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 28, 29, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 32, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 41, 41, 41, 41, 
	41, 41, 41, 41, 35, 41, 28, 42, 
	42, 42, 42, 42, 42, 42, 42, 42, 
	42, 42, 42, 42, 42, 42, 42, 42, 
	42, 42, 42, 42, 42, 28, 42, 29, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 43, 43, 
	43, 43, 43, 43, 43, 43, 29, 43, 
	32, 44, 44, 44, 44, 44, 44, 44, 
	44, 44, 44, 44, 44, 44, 44, 44, 
	44, 44, 44, 44, 44, 44, 44, 32, 
	44, 35, 45, 45, 45, 45, 45, 45, 
	45, 45, 45, 45, 45, 45, 45, 45, 
	45, 45, 45, 45, 45, 45, 45, 45, 
	35, 45, 46, 47, 48, 8, 8, 8, 
	8, 8, 8, 8, 8, 8, 50, 8, 
	8, 8, 8, 8, 8, 8, 8, 8, 
	8, 8, 8, 8, 8, 8, 8, 8, 
	8, 8, 8, 8, 8, 50, 8, 8, 
	51, 8, 8, 8, 8, 8, 52, 53, 
	5, 8, 54, 55, 8, 6, 6, 6, 
	6, 6, 6, 6, 6, 6, 6, 56, 
	8, 8, 8, 8, 8, 8, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	8, 8, 8, 8, 49, 8, 49, 49, 
	49, 49, 57, 49, 49, 49, 49, 49, 
	49, 49, 49, 58, 59, 49, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	8, 8, 8, 8, 8, 49, 60, 60, 
	60, 60, 60, 60, 60, 60, 60, 60, 
	60, 60, 60, 60, 60, 60, 60, 60, 
	60, 60, 60, 60, 60, 60, 60, 60, 
	60, 60, 60, 60, 60, 60, 60, 60, 
	60, 60, 60, 60, 60, 60, 60, 60, 
	60, 60, 60, 49, 60, 60, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	60, 60, 60, 60, 60, 60, 60, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	49, 60, 61, 60, 60, 49, 60, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	49, 49, 49, 49, 49, 49, 49, 49, 
	49, 60, 60, 60, 60, 60, 49, 62, 
	62, 62, 62, 62, 62, 62, 62, 62, 
	62, 62, 62, 62, 62, 62, 62, 62, 
	62, 62, 62, 62, 62, 62, 62, 62, 
	62, 62, 62, 62, 62, 62, 62, 62, 
	62, 62, 62, 62, 62, 62, 62, 62, 
	62, 62, 62, 62, 63, 62, 62, 63, 
	63, 63, 63, 63, 63, 63, 63, 63, 
	63, 62, 62, 62, 62, 62, 62, 62, 
	63, 63, 63, 63, 63, 63, 63, 63, 
	63, 63, 63, 63, 63, 63, 63, 63, 
	63, 63, 63, 63, 63, 63, 63, 63, 
	63, 63, 62, 64, 62, 62, 63, 62, 
	63, 63, 63, 63, 63, 63, 63, 63, 
	63, 63, 63, 63, 63, 63, 63, 63, 
	63, 63, 63, 63, 63, 63, 63, 63, 
	63, 63, 62, 62, 62, 62, 62, 63, 
	50, 65, 65, 65, 65, 65, 65, 65, 
	65, 65, 65, 65, 65, 65, 65, 65, 
	65, 65, 65, 65, 65, 65, 65, 50, 
	65, 66, 6, 6, 6, 6, 6, 6, 
	6, 6, 6, 6, 67, 5, 68, 5, 
	68, 68, 6, 6, 6, 6, 6, 6, 
	6, 6, 6, 6, 68, 69, 70, 8, 
	8, 8, 8, 8, 8, 8, 8, 8, 
	72, 8, 8, 8, 8, 8, 8, 8, 
	8, 8, 8, 8, 8, 8, 8, 8, 
	8, 8, 8, 8, 8, 8, 8, 72, 
	8, 15, 8, 73, 8, 8, 18, 8, 
	8, 74, 8, 8, 8, 8, 8, 8, 
	8, 8, 8, 8, 8, 8, 8, 8, 
	8, 8, 8, 8, 75, 8, 8, 8, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 8, 8, 76, 77, 71, 8, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 8, 78, 8, 79, 8, 71, 
	80, 80, 80, 80, 80, 80, 80, 80, 
	80, 80, 80, 80, 80, 80, 80, 80, 
	80, 80, 80, 80, 80, 80, 80, 80, 
	80, 80, 80, 80, 80, 80, 80, 80, 
	80, 80, 80, 80, 80, 80, 80, 80, 
	80, 80, 80, 80, 80, 71, 80, 80, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 80, 80, 80, 80, 80, 80, 
	80, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 80, 81, 80, 80, 71, 
	80, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 71, 71, 71, 71, 71, 
	71, 71, 71, 80, 80, 80, 80, 80, 
	71, 82, 82, 82, 82, 82, 82, 82, 
	82, 82, 82, 82, 82, 82, 82, 82, 
	82, 82, 82, 82, 82, 82, 82, 82, 
	82, 82, 82, 82, 82, 82, 82, 82, 
	82, 82, 82, 82, 82, 82, 82, 82, 
	82, 82, 82, 82, 82, 82, 83, 82, 
	82, 83, 83, 83, 83, 83, 83, 83, 
	83, 83, 83, 82, 82, 82, 82, 82, 
	82, 82, 83, 83, 83, 83, 83, 83, 
	83, 83, 83, 83, 83, 83, 83, 83, 
	83, 83, 83, 83, 83, 83, 83, 83, 
	83, 83, 83, 83, 82, 84, 82, 82, 
	83, 82, 83, 83, 83, 83, 83, 83, 
	83, 83, 83, 83, 83, 83, 83, 83, 
	83, 83, 83, 83, 83, 83, 83, 83, 
	83, 83, 83, 83, 82, 82, 82, 82, 
	82, 83, 72, 85, 85, 85, 85, 85, 
	85, 85, 85, 85, 85, 85, 85, 85, 
	85, 85, 85, 85, 85, 85, 85, 85, 
	85, 72, 85, 86, 80, 0
]

class << self
	attr_accessor :_css_lexer_trans_targs
	private :_css_lexer_trans_targs, :_css_lexer_trans_targs=
end
self._css_lexer_trans_targs = [
	16, 18, 27, 29, 27, 3, 32, 5, 
	0, 6, 27, 8, 27, 36, 38, 10, 
	36, 36, 12, 36, 36, 36, 17, 16, 
	19, 24, 16, 16, 20, 21, 25, 26, 
	22, 16, 16, 23, 16, 1, 16, 17, 
	1, 16, 16, 16, 16, 16, 16, 16, 
	16, 28, 30, 31, 27, 27, 33, 34, 
	35, 4, 27, 7, 27, 2, 27, 28, 
	2, 27, 27, 27, 27, 27, 27, 37, 
	39, 11, 40, 36, 36, 13, 14, 15, 
	36, 9, 36, 37, 9, 36, 36
]

class << self
	attr_accessor :_css_lexer_trans_actions
	private :_css_lexer_trans_actions, :_css_lexer_trans_actions=
end
self._css_lexer_trans_actions = [
	1, 2, 3, 2, 4, 0, 0, 0, 
	0, 0, 5, 0, 6, 7, 2, 0, 
	8, 9, 0, 10, 11, 12, 2, 15, 
	0, 0, 16, 17, 0, 0, 0, 0, 
	0, 18, 19, 0, 20, 0, 21, 22, 
	23, 24, 25, 26, 27, 28, 29, 30, 
	31, 2, 0, 0, 33, 34, 35, 0, 
	0, 0, 36, 0, 37, 0, 38, 22, 
	23, 39, 40, 41, 42, 43, 44, 2, 
	0, 0, 0, 45, 46, 0, 0, 0, 
	47, 0, 48, 22, 23, 49, 50
]

class << self
	attr_accessor :_css_lexer_to_state_actions
	private :_css_lexer_to_state_actions, :_css_lexer_to_state_actions=
end
self._css_lexer_to_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	13, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 32, 0, 0, 0, 0, 
	0, 0, 0, 0, 13, 0, 0, 0, 
	0
]

class << self
	attr_accessor :_css_lexer_from_state_actions
	private :_css_lexer_from_state_actions, :_css_lexer_from_state_actions=
end
self._css_lexer_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	14, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 14, 0, 0, 0, 0, 
	0, 0, 0, 0, 14, 0, 0, 0, 
	0
]

class << self
	attr_accessor :_css_lexer_eof_trans
	private :_css_lexer_eof_trans, :_css_lexer_eof_trans=
end
self._css_lexer_eof_trans = [
	0, 1, 3, 5, 0, 0, 0, 0, 
	0, 14, 0, 0, 0, 0, 0, 0, 
	0, 37, 39, 42, 43, 44, 45, 46, 
	47, 48, 49, 0, 61, 63, 66, 67, 
	68, 69, 70, 71, 0, 81, 83, 86, 
	81
]

class << self
	attr_accessor :css_lexer_start
end
self.css_lexer_start = 16;
class << self
	attr_accessor :css_lexer_first_final
end
self.css_lexer_first_final = 16;
class << self
	attr_accessor :css_lexer_error
end
self.css_lexer_error = 0;

class << self
	attr_accessor :css_lexer_en_pseudo_args
end
self.css_lexer_en_pseudo_args = 27;
class << self
	attr_accessor :css_lexer_en_predicate
end
self.css_lexer_en_predicate = 36;
class << self
	attr_accessor :css_lexer_en_main
end
self.css_lexer_en_main = 16;


# line 21 "lib/oga/css/lexer.rl"

      # % fix highlight

      # @param [String] data The data to lex.
      def initialize(data)
        @data = data.strip
      end

      # Gathers all the tokens for the input and returns them as an Array.
      #
      # @see [#advance]
      # @return [Array]
      def lex
        tokens = []

        advance do |type, value|
          tokens << [type, value]
        end

        return tokens
      end

      # Advances through the input and generates the corresponding tokens. Each
      # token is yielded to the supplied block.
      #
      # This method stores the supplied block in `@block` and resets it after
      # the lexer loop has finished.
      #
      # @see [#add_token]
      def advance(&block)
        @block   = block
        @escaped = false

        data  = @data # saves ivar lookups while lexing.
        ts    = nil
        te    = nil
        stack = []
        top   = 0
        cs    = self.class.css_lexer_start
        act   = 0
        eof   = @data.bytesize
        p     = 0
        pe    = eof

        _css_lexer_eof_trans          = self.class.send(:_css_lexer_eof_trans)
        _css_lexer_from_state_actions = self.class.send(:_css_lexer_from_state_actions)
        _css_lexer_index_offsets      = self.class.send(:_css_lexer_index_offsets)
        _css_lexer_indicies           = self.class.send(:_css_lexer_indicies)
        _css_lexer_key_spans          = self.class.send(:_css_lexer_key_spans)
        _css_lexer_to_state_actions   = self.class.send(:_css_lexer_to_state_actions)
        _css_lexer_trans_actions      = self.class.send(:_css_lexer_trans_actions)
        _css_lexer_trans_keys         = self.class.send(:_css_lexer_trans_keys)
        _css_lexer_trans_targs        = self.class.send(:_css_lexer_trans_targs)

        
# line 428 "lib/oga/css/lexer.rb"
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
	case _css_lexer_from_state_actions[cs] 
	when 14 then
# line 1 "NONE"
		begin
ts = p
		end
# line 456 "lib/oga/css/lexer.rb"
	end
	_keys = cs << 1
	_inds = _css_lexer_index_offsets[cs]
	_slen = _css_lexer_key_spans[cs]
	_wide = ( (data.getbyte(p) || 0))
	_trans = if (   _slen > 0 && 
			_css_lexer_trans_keys[_keys] <= _wide && 
			_wide <= _css_lexer_trans_keys[_keys + 1] 
		    ) then
			_css_lexer_indicies[ _inds + _wide - _css_lexer_trans_keys[_keys] ] 
		 else 
			_css_lexer_indicies[ _inds + _slen ]
		 end
	end
	if _goto_level <= _eof_trans
	cs = _css_lexer_trans_targs[_trans]
	if _css_lexer_trans_actions[_trans] != 0
	case _css_lexer_trans_actions[_trans]
	when 23 then
# line 151 "lib/oga/css/lexer.rl"
		begin
 @escaped = true 		end
	when 2 then
# line 1 "NONE"
		begin
te = p+1
		end
	when 36 then
# line 253 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_NTH)  end
		end
	when 6 then
# line 255 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_ODD)  end
		end
	when 5 then
# line 256 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_EVEN)  end
		end
	when 33 then
# line 235 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin 
          add_token(:T_RPAREN)

          cs = 16;
         end
		end
	when 34 then
# line 158 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 39 then
# line 246 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 42 then
# line 254 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin  add_token(:T_MINUS)  end
		end
	when 41 then
# line 196 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          value = slice_input(ts, te).to_i

          add_token(:T_INT, value)
         end
		end
	when 37 then
# line 158 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 3 then
# line 158 "lib/oga/css/lexer.rl"
		begin
 begin p = ((te))-1; end
 begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 4 then
# line 1 "NONE"
		begin
	case act
	when 0 then
	begin	begin
		cs = 0
		_goto_level = _again
		next
	end
end
	when 4 then
	begin begin p = ((te))-1; end
 add_token(:T_MINUS) end
end 
			end
	when 45 then
# line 294 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_EQ)  end
		end
	when 12 then
# line 295 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_SPACE_IN)  end
		end
	when 10 then
# line 296 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_STARTS_WITH)  end
		end
	when 9 then
# line 297 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_ENDS_WITH)  end
		end
	when 50 then
# line 298 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_IN)  end
		end
	when 11 then
# line 299 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin  add_token(:T_HYPHEN_IN)  end
		end
	when 46 then
# line 276 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin 
          add_token(:T_RBRACK)

          cs = 16;
         end
		end
	when 8 then
# line 214 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin 
          emit(:T_STRING, ts + 1, te - 1)
         end
		end
	when 49 then
# line 284 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 47 then
# line 158 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 7 then
# line 158 "lib/oga/css/lexer.rl"
		begin
 begin p = ((te))-1; end
 begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 18 then
# line 270 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin 
          add_token(:T_LBRACK)

          cs = 36;
         end
		end
	when 19 then
# line 134 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin 
          add_token(:T_PIPE)
         end
		end
	when 16 then
# line 229 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin 
          add_token(:T_LPAREN)

          cs = 27;
         end
		end
	when 17 then
# line 158 "lib/oga/css/lexer.rl"
		begin
te = p+1
 begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 15 then
# line 319 "lib/oga/css/lexer.rl"
		begin
te = p+1
		end
	when 27 then
# line 308 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin  add_token(:T_GREATER)  end
		end
	when 25 then
# line 309 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin  add_token(:T_PLUS)  end
		end
	when 28 then
# line 310 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin  add_token(:T_TILDE)  end
		end
	when 26 then
# line 138 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          add_token(:T_COMMA)
         end
		end
	when 24 then
# line 124 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          add_token(:T_SPACE)
         end
		end
	when 20 then
# line 158 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 1 then
# line 158 "lib/oga/css/lexer.rl"
		begin
 begin p = ((te))-1; end
 begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 40 then
# line 128 "lib/oga/css/lexer.rl"
		begin
 add_token(:T_HASH) 		end
# line 248 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 29 then
# line 128 "lib/oga/css/lexer.rl"
		begin
 add_token(:T_HASH) 		end
# line 306 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 43 then
# line 129 "lib/oga/css/lexer.rl"
		begin
 add_token(:T_DOT) 		end
# line 248 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 30 then
# line 129 "lib/oga/css/lexer.rl"
		begin
 add_token(:T_DOT) 		end
# line 306 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 44 then
# line 130 "lib/oga/css/lexer.rl"
		begin
 add_token(:T_COLON) 		end
# line 248 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 31 then
# line 130 "lib/oga/css/lexer.rl"
		begin
 add_token(:T_COLON) 		end
# line 306 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1;		end
	when 38 then
# line 151 "lib/oga/css/lexer.rl"
		begin
 @escaped = true 		end
# line 158 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 48 then
# line 151 "lib/oga/css/lexer.rl"
		begin
 @escaped = true 		end
# line 158 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 21 then
# line 151 "lib/oga/css/lexer.rl"
		begin
 @escaped = true 		end
# line 158 "lib/oga/css/lexer.rl"
		begin
te = p
p = p - 1; begin 
          value = slice_input(ts, te)

          # Translates "foo\.bar" into "foo.bar"
          if @escaped
            value    = value.gsub('\.', '.')
            @escaped = false
          end

          add_token(:T_IDENT, value)
         end
		end
	when 22 then
# line 1 "NONE"
		begin
te = p+1
		end
# line 151 "lib/oga/css/lexer.rl"
		begin
 @escaped = true 		end
	when 35 then
# line 1 "NONE"
		begin
te = p+1
		end
# line 254 "lib/oga/css/lexer.rl"
		begin
act = 4;		end
# line 924 "lib/oga/css/lexer.rb"
	end
	end
	end
	if _goto_level <= _again
	case _css_lexer_to_state_actions[cs] 
	when 13 then
# line 1 "NONE"
		begin
ts = nil;		end
	when 32 then
# line 1 "NONE"
		begin
ts = nil;		end
# line 1 "NONE"
		begin
act = 0
		end
# line 942 "lib/oga/css/lexer.rb"
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
	if _css_lexer_eof_trans[cs] > 0
		_trans = _css_lexer_eof_trans[cs] - 1;
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

# line 76 "lib/oga/css/lexer.rl"

        # % fix highlight
      ensure
        @block = nil
      end

      private

      # Emits a token of which the value is based on the supplied start/stop
      # position.
      #
      # @param [Symbol] type The token type.
      # @param [Fixnum] start
      # @param [Fixnum] stop
      #
      # @see [#text]
      # @see [#add_token]
      def emit(type, start, stop)
        value = slice_input(start, stop)

        add_token(type, value)
      end

      # Returns the text between the specified start and stop position.
      #
      # @param [Fixnum] start
      # @param [Fixnum] stop
      # @return [String]
      def slice_input(start, stop)
        return @data.byteslice(start, stop - start)
      end

      # Yields a new token to the supplied block.
      #
      # @param [Symbol] type The token type.
      # @param [String] value The token value.
      #
      # @yieldparam [Symbol] type
      # @yieldparam [String|NilClass] value
      def add_token(type, value = nil)
        @block.call(type, value)
      end

      
# line 321 "lib/oga/css/lexer.rl"

    end # Lexer
  end # CSS
end # Oga
