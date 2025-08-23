# -*- frozen_string_literal: true; warn-indent: false -*-
#
# THIS IS A GENERATED FILE, DO NOT EDIT DIRECTLY
#
# This file was generated from scanner.rl
# by running `$ bundle exec rake ragel`


require_relative 'scanner/errors/scanner_error'
require_relative 'scanner/errors/premature_end_error'
require_relative 'scanner/errors/validation_error'

class Regexp::Scanner
  # Scans the given regular expression text, or Regexp object and collects the
  # emitted token into an array that gets returned at the end. If a block is
  # given, it gets called for each emitted token.
  #
  # This method may raise errors if a syntax error is encountered.
  # --------------------------------------------------------------------------
  def self.scan(input_object, options: nil, collect_tokens: true, &block)
    new.scan(input_object, options: options, collect_tokens: collect_tokens, &block)
  end

  def scan(input_object, options: nil, collect_tokens: true, &block)
    self.collect_tokens = collect_tokens
    self.literal_run = nil
    stack = []

    input = input_object.is_a?(Regexp) ? input_object.source : input_object
    self.free_spacing = free_spacing?(input_object, options)
    self.regexp_encoding = extract_encoding(input_object, options)
    self.spacing_stack = [{:free_spacing => free_spacing, :depth => 0}]

    data  = input.unpack("c*")
    eof   = data.length

    self.tokens = []
    self.block  = block

    self.set_depth = 0
    self.group_depth = 0
    self.capturing_group_count = 0
    self.conditional_stack = []
    self.char_pos = 0

class << self
	attr_accessor :_re_scanner_trans_keys
	private :_re_scanner_trans_keys, :_re_scanner_trans_keys=
end
self._re_scanner_trans_keys = [
0,0,-128,-65,-128,-65,
-128,-65,41,41,39,
57,39,39,33,62,
62,62,39,60,39,57,
39,39,48,57,39,
57,48,57,39,57,
33,62,62,62,48,57,
43,62,48,57,48,
62,39,60,39,57,
39,39,48,57,39,57,
48,57,39,57,33,
62,62,62,48,57,
43,62,48,57,48,62,
48,57,48,125,44,
125,123,123,9,122,
9,125,9,122,-128,-65,
-128,-65,38,38,58,
93,58,93,-128,-65,
-128,-65,45,45,92,92,
92,92,45,45,92,
92,92,92,48,123,
48,102,48,102,48,102,
48,102,9,125,9,
125,9,125,9,125,
9,125,9,125,48,102,
120,120,56,102,48,
102,39,39,41,41,
41,57,62,62,-128,127,
-62,-12,1,127,1,
127,9,32,33,126,
10,10,63,63,33,126,
33,126,43,63,43,
63,43,63,65,122,
44,57,68,119,80,112,
-62,125,-128,-65,-128,
-65,-128,-65,38,38,
38,93,58,58,48,120,
48,55,48,55,-62,
125,-128,-65,-128,-65,
-128,-65,48,55,48,55,
48,57,48,57,48,
57,48,57,77,77,
45,45,0,0,67,99,
45,45,0,0,92,
92,48,102,48,102,
92,92,39,60,39,57,
48,57,41,57,33,
62,0
]

class << self
	attr_accessor :_re_scanner_key_spans
	private :_re_scanner_key_spans, :_re_scanner_key_spans=
end
self._re_scanner_key_spans = [
0,64,64,64,1,19,1,30,
1,22,19,1,10,19,10,19,
30,1,10,20,10,15,22,19,
1,10,19,10,19,30,1,10,
20,10,15,10,78,82,1,114,
117,114,64,64,1,36,36,64,
64,1,1,1,1,1,1,76,
55,55,55,55,117,117,117,117,
117,117,55,1,47,55,1,1,
17,1,256,51,127,127,24,94,
1,1,94,94,21,21,21,58,
14,52,33,188,64,64,64,1,
56,1,73,8,8,188,64,64,
64,8,8,10,10,10,10,1,
1,0,33,1,0,1,55,55,
1,22,19,10,17,30
]

class << self
	attr_accessor :_re_scanner_index_offsets
	private :_re_scanner_index_offsets, :_re_scanner_index_offsets=
end
self._re_scanner_index_offsets = [
0,0,65,130,195,197,217,219,
250,252,275,295,297,308,328,339,
359,390,392,403,424,435,451,474,
494,496,507,527,538,558,589,591,
602,623,634,650,661,740,823,825,
940,1058,1173,1238,1303,1305,1342,1379,
1444,1509,1511,1513,1515,1517,1519,1521,
1598,1654,1710,1766,1822,1940,2058,2176,
2294,2412,2530,2586,2588,2636,2692,2694,
2696,2714,2716,2973,3025,3153,3281,3306,
3401,3403,3405,3500,3595,3617,3639,3661,
3720,3735,3788,3822,4011,4076,4141,4206,
4208,4265,4267,4341,4350,4359,4548,4613,
4678,4743,4752,4761,4772,4783,4794,4805,
4807,4809,4810,4844,4846,4847,4849,4905,
4961,4963,4986,5006,5017,5035
]

class << self
	attr_accessor :_re_scanner_indicies
	private :_re_scanner_indicies, :_re_scanner_indicies=
end
self._re_scanner_indicies = [
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,
0,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,0,3,3,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,0,6,5,8,7,7,
7,7,7,4,7,7,4,4,
4,4,4,4,4,4,4,4,
7,8,7,10,9,9,9,9,
9,9,9,9,9,9,9,4,
9,9,4,4,4,4,4,4,
4,4,4,4,9,9,9,10,
8,9,8,9,12,11,11,11,
11,11,11,11,11,11,11,11,
11,11,11,11,11,11,11,11,
11,13,11,15,14,14,14,14,
14,16,14,14,17,17,17,17,
17,17,17,17,17,17,14,15,
14,17,17,17,17,17,17,17,
17,17,17,11,15,11,11,11,
18,11,18,11,11,17,17,17,
17,17,17,17,17,17,17,11,
19,19,19,19,19,19,19,19,
19,19,11,15,11,11,11,11,
11,11,11,11,19,19,19,19,
19,19,19,19,19,19,11,11,
20,20,20,20,20,20,20,20,
20,20,20,21,20,20,22,22,
22,22,22,22,22,22,22,22,
20,20,20,11,15,20,15,20,
22,22,22,22,22,22,22,22,
22,22,11,23,11,23,11,11,
22,22,22,22,22,22,22,22,
22,22,11,11,11,11,15,11,
24,24,24,24,24,24,24,24,
24,24,11,24,24,24,24,24,
24,24,24,24,24,11,11,11,
11,15,11,25,11,11,11,11,
11,11,11,11,11,11,11,11,
11,11,11,11,11,11,11,11,
26,11,28,27,27,27,27,27,
29,27,27,30,30,30,30,30,
30,30,30,30,30,27,28,27,
30,30,30,30,30,30,30,30,
30,30,11,28,11,11,11,31,
11,31,11,11,30,30,30,30,
30,30,30,30,30,30,11,32,
32,32,32,32,32,32,32,32,
32,11,28,11,11,11,11,11,
11,11,11,32,32,32,32,32,
32,32,32,32,32,11,11,33,
33,33,33,33,33,33,33,33,
33,33,34,33,33,35,35,35,
35,35,35,35,35,35,35,33,
33,33,11,28,33,28,33,35,
35,35,35,35,35,35,35,35,
35,11,36,11,36,11,11,35,
35,35,35,35,35,35,35,35,
35,11,11,11,11,28,11,37,
37,37,37,37,37,37,37,37,
37,11,37,37,37,37,37,37,
37,37,37,37,11,11,11,11,
28,11,39,39,39,39,39,39,
39,39,39,39,38,39,39,39,
39,39,39,39,39,39,39,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,40,38,39,38,38,38,
41,41,41,41,41,41,41,41,
41,41,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,38,38,38,
38,38,38,38,38,40,38,42,
43,44,44,44,44,44,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
44,43,43,43,43,43,43,43,
43,43,43,43,43,44,44,43,
44,44,44,44,44,44,44,44,
44,44,43,43,43,44,43,43,
43,44,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,43,43,43,45,44,
43,44,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,43,44,44,44,44,
44,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,44,43,43,43,43,
43,43,43,43,43,43,43,43,
44,44,43,44,44,44,44,44,
44,44,44,44,44,43,43,43,
44,43,43,43,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,44,44,43,43,
43,43,44,43,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,44,44,43,43,
46,43,44,44,44,44,44,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,44,43,43,43,43,43,43,
43,43,43,43,43,43,44,44,
43,44,44,44,44,44,44,44,
44,44,44,43,43,43,44,43,
43,43,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,43,43,43,43,
44,43,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,44,44,44,44,
44,44,44,44,43,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,47,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,47,51,
50,54,53,53,53,53,53,53,
53,53,53,53,53,53,53,53,
53,53,53,53,53,53,53,53,
53,53,53,53,53,53,53,53,
53,53,55,53,55,53,54,53,
53,53,53,53,53,53,53,53,
53,53,53,53,53,53,53,53,
53,53,53,53,53,53,53,53,
53,53,53,53,53,53,53,55,
53,56,53,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,57,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,57,60,43,62,
61,64,61,65,43,67,66,69,
66,70,70,70,70,70,70,70,
70,70,70,43,43,43,43,43,
43,43,70,70,70,70,70,70,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,70,70,70,70,70,70,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,71,43,72,72,
72,72,72,72,72,72,72,72,
43,43,43,43,43,43,43,72,
72,72,72,72,72,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,72,
72,72,72,72,72,43,73,73,
73,73,73,73,73,73,73,73,
43,43,43,43,43,43,43,73,
73,73,73,73,73,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,73,
73,73,73,73,73,43,74,74,
74,74,74,74,74,74,74,74,
43,43,43,43,43,43,43,74,
74,74,74,74,74,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,74,
74,74,74,74,74,43,75,75,
75,75,75,75,75,75,75,75,
43,43,43,43,43,43,43,75,
75,75,75,75,75,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,75,
75,75,75,75,75,43,71,71,
71,71,71,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,71,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,76,76,76,
76,76,76,76,76,76,76,43,
43,43,43,43,43,43,76,76,
76,76,76,76,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,76,76,
76,76,76,76,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,74,43,71,71,71,71,
71,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,71,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,77,77,77,77,77,
77,77,77,77,77,43,43,43,
43,43,43,43,77,77,77,77,
77,77,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,77,77,77,77,
77,77,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
74,43,71,71,71,71,71,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,71,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,78,78,78,78,78,78,78,
78,78,78,43,43,43,43,43,
43,43,78,78,78,78,78,78,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,78,78,78,78,78,78,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,74,43,
71,71,71,71,71,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,71,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,79,
79,79,79,79,79,79,79,79,
79,43,43,43,43,43,43,43,
79,79,79,79,79,79,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
79,79,79,79,79,79,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,74,43,71,71,
71,71,71,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,71,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,80,80,80,
80,80,80,80,80,80,80,43,
43,43,43,43,43,43,80,80,
80,80,80,80,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,80,80,
80,80,80,80,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,74,43,71,71,71,71,
71,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,71,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
74,43,82,82,82,82,82,82,
82,82,83,83,81,81,81,81,
81,81,81,83,83,83,83,83,
83,81,81,81,81,81,81,81,
81,81,81,81,81,81,81,81,
81,81,81,81,81,81,81,81,
81,81,81,83,83,83,83,83,
83,81,85,84,86,86,84,84,
84,84,84,84,84,86,86,86,
86,86,86,84,84,84,84,84,
84,84,84,84,84,84,84,84,
84,84,84,84,84,84,84,84,
84,84,84,84,84,86,86,86,
86,86,86,84,87,87,87,87,
87,87,87,87,87,87,84,84,
84,84,84,84,84,87,87,87,
87,87,87,84,84,84,84,84,
84,84,84,84,84,84,84,84,
84,84,84,84,84,84,84,84,
84,84,84,84,84,87,87,87,
87,87,87,84,90,89,91,88,
91,88,88,88,88,88,88,92,
92,92,92,92,92,92,92,92,
92,88,90,93,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,3,3,94,94,94,94,
94,43,43,43,43,43,43,43,
43,43,43,43,43,95,95,95,
95,95,95,95,95,96,96,96,
96,96,95,95,95,95,95,95,
95,95,95,95,95,95,95,95,
95,95,95,95,97,98,98,99,
100,98,98,98,101,102,103,104,
98,98,105,98,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,106,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,107,
108,109,110,98,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,111,
112,109,98,95,98,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,2,2,2,2,2,
2,2,2,3,3,3,3,3,
3,3,3,3,3,3,3,3,
3,3,3,94,94,94,94,94,
113,95,95,95,95,95,95,95,
95,95,95,95,95,95,95,95,
95,95,95,95,95,95,95,95,
95,95,95,95,95,95,95,95,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,113,
113,113,113,113,113,113,113,95,
113,95,95,95,95,95,95,95,
95,96,96,96,96,96,95,95,
95,95,95,95,95,95,95,95,
95,95,95,95,95,95,95,95,
97,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,95,
114,97,97,97,97,97,114,114,
114,114,114,114,114,114,114,114,
114,114,114,114,114,114,114,114,
97,114,98,98,113,113,98,98,
98,113,113,113,113,98,98,113,
98,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,98,
113,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,98,113,113,113,113,
98,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,98,
98,98,98,98,113,113,113,98,
113,116,99,118,117,10,120,5,
120,120,120,121,122,119,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,8,120,
123,10,8,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,8,120,119,120,119,120,
120,120,119,119,119,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,124,120,119,
119,119,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,120,120,120,120,120,120,120,
120,119,120,126,125,125,125,125,
125,125,125,125,125,125,125,125,
125,125,125,125,125,125,125,126,
125,128,127,127,127,127,127,127,
127,127,127,127,127,127,127,127,
127,127,127,127,127,128,127,130,
129,129,129,129,129,129,129,129,
129,129,129,129,129,129,129,129,
129,129,129,130,129,132,132,131,
131,131,131,132,131,131,131,133,
131,131,131,131,131,131,131,131,
131,131,131,131,131,131,132,131,
131,131,131,131,131,131,132,131,
131,131,131,134,131,131,131,135,
131,131,131,131,131,131,131,131,
131,131,131,131,131,131,132,131,
137,136,136,136,41,41,41,41,
41,41,41,41,41,41,136,138,
43,43,43,138,43,43,43,43,
43,43,43,43,43,138,138,43,
43,43,138,138,43,43,43,43,
43,43,43,43,43,43,43,138,
43,43,43,138,43,43,43,43,
43,43,43,43,43,43,138,43,
43,43,138,43,139,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,43,43,43,43,
43,43,43,43,139,43,140,140,
140,140,140,140,140,140,140,140,
140,140,140,140,140,140,140,140,
140,140,140,140,140,140,140,140,
140,140,140,140,141,141,141,141,
141,141,141,141,141,141,141,141,
141,141,141,141,142,142,142,142,
142,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
143,48,144,48,143,143,143,143,
48,145,143,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,143,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,146,
147,148,149,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,143,
143,143,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,48,48,48,48,48,
48,48,48,150,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,49,49,49,49,
49,49,49,49,150,151,151,151,
151,151,151,151,151,151,151,151,
151,151,151,151,151,151,151,151,
151,151,151,151,151,151,151,151,
151,151,151,151,151,151,151,151,
151,151,151,151,151,151,151,151,
151,151,151,151,151,151,151,151,
151,151,151,151,151,151,151,151,
151,151,151,151,151,150,152,150,
154,153,153,153,153,153,153,153,
153,153,153,153,153,153,153,153,
153,153,153,153,153,153,153,153,
153,153,153,153,153,153,153,153,
153,153,153,153,153,153,153,153,
153,153,153,153,153,153,153,153,
153,153,153,153,153,153,153,155,
153,53,157,159,159,159,159,159,
159,159,159,158,158,158,158,158,
158,158,158,158,158,158,160,160,
158,158,158,160,158,158,158,158,
160,158,158,160,158,158,160,158,
158,158,160,158,158,158,160,160,
160,158,158,158,160,160,160,160,
160,160,158,160,158,158,158,158,
158,160,158,160,158,160,160,160,
160,160,160,160,158,162,162,162,
162,162,162,162,162,161,163,163,
163,163,163,163,163,163,161,164,
164,164,164,164,164,164,164,164,
164,164,164,164,164,164,164,164,
164,164,164,164,164,164,164,164,
164,164,164,164,164,165,165,165,
165,165,165,165,165,165,165,165,
165,165,165,165,165,166,166,166,
166,166,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,167,58,58,58,167,167,167,
167,58,58,167,58,168,169,169,
169,169,169,169,169,170,170,58,
58,58,58,58,167,58,43,43,
171,172,58,58,43,172,58,58,
43,58,173,58,58,174,58,172,
172,58,58,58,172,172,58,43,
167,167,167,167,58,58,175,175,
60,172,175,175,58,172,58,58,
58,58,58,175,58,174,58,175,
172,175,176,175,172,177,58,43,
167,167,167,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,58,58,58,58,
58,58,58,58,178,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,59,59,59,
59,59,59,59,59,178,179,179,
179,179,179,179,179,179,179,179,
179,179,179,179,179,179,179,179,
179,179,179,179,179,179,179,179,
179,179,179,179,179,179,179,179,
179,179,179,179,179,179,179,179,
179,179,179,179,179,179,179,179,
179,179,179,179,179,179,179,179,
179,179,179,179,179,179,178,181,
181,181,181,181,181,181,181,180,
182,182,182,182,182,182,182,182,
180,184,184,184,184,184,184,184,
184,185,185,183,185,185,185,185,
185,185,185,185,185,185,183,185,
185,185,185,185,185,185,185,185,
185,183,185,185,185,185,185,185,
185,185,185,185,183,187,61,189,
188,61,191,66,66,66,66,66,
66,66,66,66,66,66,66,66,
66,66,66,66,66,66,66,66,
66,66,66,66,66,66,66,66,
66,66,192,66,194,193,66,69,
66,196,196,196,196,196,196,196,
196,196,196,195,195,195,195,195,
195,195,196,196,196,196,196,196,
195,195,195,195,195,195,195,195,
195,195,195,195,195,195,195,195,
195,195,195,195,195,195,195,195,
195,195,196,196,196,196,196,196,
195,87,87,87,87,87,87,87,
87,87,87,195,195,195,195,195,
195,195,87,87,87,87,87,87,
195,195,195,195,195,195,195,195,
195,195,195,195,195,195,195,195,
195,195,195,195,195,195,195,195,
195,195,87,87,87,87,87,87,
195,198,197,200,199,199,199,199,
199,201,199,199,202,202,202,202,
202,202,202,202,202,202,199,199,
203,199,90,89,89,89,89,89,
204,89,89,204,204,204,204,204,
204,204,204,204,204,89,92,92,
92,92,92,92,92,92,92,92,
204,91,204,204,204,204,204,204,
92,92,92,92,92,92,92,92,
92,92,204,204,93,93,93,93,
93,93,93,93,93,93,93,204,
93,93,204,204,204,204,204,204,
204,204,204,204,93,93,93,204,
90,93,0
]

class << self
	attr_accessor :_re_scanner_trans_targs
	private :_re_scanner_trans_targs, :_re_scanner_trans_targs=
end
self._re_scanner_trans_targs = [
74,75,1,2,74,4,74,6,
74,8,74,74,10,16,11,74,
12,13,14,15,17,18,19,20,
21,23,29,24,74,25,26,27,
28,30,31,32,33,34,74,36,
74,37,39,0,40,41,90,91,
91,42,91,91,91,45,46,91,
91,101,101,47,50,101,111,101,
113,53,101,114,101,116,56,59,
57,58,101,60,61,62,63,64,
65,101,118,119,101,68,69,120,
121,70,71,121,72,73,3,76,
77,78,79,80,74,81,74,84,
85,74,86,74,87,74,74,88,
74,74,74,74,74,74,82,74,
83,5,74,7,74,74,74,74,
74,74,74,74,74,74,9,22,
74,35,89,38,92,93,94,91,
95,96,97,91,91,91,91,43,
91,91,44,91,91,91,98,99,
98,98,100,98,102,103,104,101,
105,107,110,49,101,52,101,101,
55,66,101,48,101,106,101,101,
108,109,101,112,101,51,101,115,
117,101,54,101,101,101,67,121,
122,123,124,125,121
]

class << self
	attr_accessor :_re_scanner_trans_actions
	private :_re_scanner_trans_actions, :_re_scanner_trans_actions=
end
self._re_scanner_trans_actions = [
1,2,0,0,3,0,4,0,
5,0,6,7,0,0,0,8,
0,0,0,0,0,0,0,0,
0,0,0,0,9,0,0,0,
0,0,0,0,0,0,10,0,
11,0,0,0,0,0,13,14,
15,0,16,17,18,0,0,19,
20,21,22,0,0,24,0,25,
0,0,26,0,27,0,0,0,
0,0,28,0,0,0,0,0,
0,29,0,0,30,0,0,31,
32,0,0,33,0,0,0,0,
0,0,0,0,36,37,38,0,
0,39,0,40,31,41,42,31,
43,44,45,46,47,48,31,49,
0,0,50,0,51,52,53,54,
55,56,57,58,59,60,0,0,
61,0,63,0,0,31,31,64,
0,31,65,66,67,68,69,0,
70,71,0,72,73,74,75,0,
76,77,0,78,0,31,31,79,
0,0,0,0,80,0,81,82,
0,0,83,0,84,0,85,86,
0,0,87,31,88,0,89,31,
0,90,0,91,92,93,0,94,
31,31,31,31,95
]

class << self
	attr_accessor :_re_scanner_to_state_actions
	private :_re_scanner_to_state_actions, :_re_scanner_to_state_actions=
end
self._re_scanner_to_state_actions = [
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,34,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,62,62,62,0,0,0,0,
0,0,62,0,0,62,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,62,0,0,0,0
]

class << self
	attr_accessor :_re_scanner_from_state_actions
	private :_re_scanner_from_state_actions, :_re_scanner_from_state_actions=
end
self._re_scanner_from_state_actions = [
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,35,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,35,35,35,0,0,0,0,
0,0,35,0,0,35,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,35,0,0,0,0
]

class << self
	attr_accessor :_re_scanner_eof_actions
	private :_re_scanner_eof_actions, :_re_scanner_eof_actions=
end
self._re_scanner_eof_actions = [
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,12,12,
12,12,0,0,0,0,0,0,
0,23,23,0,23,23,0,23,
23,23,23,23,23,23,23,23,
23,23,23,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,23,0,0,0,0,
0,0,0,0,0,23,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,0,0,0,0,0
]

class << self
	attr_accessor :_re_scanner_eof_trans
	private :_re_scanner_eof_trans, :_re_scanner_eof_trans=
end
self._re_scanner_eof_trans = [
0,1,1,1,5,5,5,5,
5,12,12,12,12,12,12,12,
12,12,12,12,12,12,12,12,
12,12,12,12,12,12,12,12,
12,12,12,39,39,39,0,0,
0,0,48,48,51,53,53,58,
58,0,0,64,0,0,69,0,
0,0,0,0,0,0,0,0,
0,0,0,85,85,85,89,89,
89,89,0,114,114,115,115,114,
116,118,120,120,126,128,130,132,
137,0,0,0,151,151,151,151,
154,157,0,162,162,0,179,179,
179,181,181,184,184,184,184,187,
187,187,191,191,191,191,196,196,
198,0,205,205,205,205
]

class << self
	attr_accessor :re_scanner_start
end
self.re_scanner_start = 74;
class << self
	attr_accessor :re_scanner_first_final
end
self.re_scanner_first_final = 74;
class << self
	attr_accessor :re_scanner_error
end
self.re_scanner_error = 0;

class << self
	attr_accessor :re_scanner_en_char_type
end
self.re_scanner_en_char_type = 89;
class << self
	attr_accessor :re_scanner_en_unicode_property
end
self.re_scanner_en_unicode_property = 90;
class << self
	attr_accessor :re_scanner_en_character_set
end
self.re_scanner_en_character_set = 91;
class << self
	attr_accessor :re_scanner_en_set_escape_sequence
end
self.re_scanner_en_set_escape_sequence = 98;
class << self
	attr_accessor :re_scanner_en_escape_sequence
end
self.re_scanner_en_escape_sequence = 101;
class << self
	attr_accessor :re_scanner_en_conditional_expression
end
self.re_scanner_en_conditional_expression = 121;
class << self
	attr_accessor :re_scanner_en_main
end
self.re_scanner_en_main = 74;

begin
	p ||= 0
	pe ||= data.length
	cs = re_scanner_start
	top = 0
	ts = nil
	te = nil
	act = 0
end

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
	case _re_scanner_from_state_actions[cs]
	when 35 then
		begin
ts = p
		end
	end
	_keys = cs << 1
	_inds = _re_scanner_index_offsets[cs]
	_slen = _re_scanner_key_spans[cs]
	_wide = data[p].ord
	_trans = if (   _slen > 0 &&
			_re_scanner_trans_keys[_keys] <= _wide &&
			_wide <= _re_scanner_trans_keys[_keys + 1]
		    ) then
			_re_scanner_indicies[ _inds + _wide - _re_scanner_trans_keys[_keys] ]
		 else
			_re_scanner_indicies[ _inds + _slen ]
		 end
	end
	if _goto_level <= _eof_trans
	cs = _re_scanner_trans_targs[_trans]
	if _re_scanner_trans_actions[_trans] != 0
	case _re_scanner_trans_actions[_trans]
	when 37 then
		begin
 self.group_depth = group_depth + 1 		end
	when 31 then
		begin
te = p+1
		end
	when 63 then
		begin
te = p+1
 begin
      case text = copy(data, ts-1,te)
      when '\d'; emit(:type, :digit,      text)
      when '\D'; emit(:type, :nondigit,   text)
      when '\h'; emit(:type, :hex,        text)
      when '\H'; emit(:type, :nonhex,     text)
      when '\s'; emit(:type, :space,      text)
      when '\S'; emit(:type, :nonspace,   text)
      when '\w'; emit(:type, :word,       text)
      when '\W'; emit(:type, :nonword,    text)
      when '\R'; emit(:type, :linebreak,  text)
      when '\X'; emit(:type, :xgrapheme,  text)
      end
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 13 then
		begin
te = p+1
 begin
      text = copy(data, ts-1,te)
      type = (text[1] == 'P') ^ (text[3] == '^') ? :nonproperty : :property

      name = text[3..-2].gsub(/[\^\s_\-]/, '').downcase

      token = self.class.short_prop_map[name] || self.class.long_prop_map[name]
      raise ValidationError.for(:property, name) unless token

      self.emit(type, token.to_sym, text)

      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 17 then
		begin
te = p+1
 begin  # special case, emits two tokens
      emit(:literal, :literal, '-')
      emit(:set, :intersection, '&&')
     end
		end
	when 68 then
		begin
te = p+1
 begin
      if prev_token[1] == :open
        emit(:set, :negate, '^')
      else
        emit(:literal, :literal, '^')
      end
     end
		end
	when 70 then
		begin
te = p+1
 begin
      emit(:set, :intersection, '&&')
     end
		end
	when 66 then
		begin
te = p+1
 begin
      	begin
		stack[top] = cs
		top+= 1
		cs = 98
		_goto_level = _again
		next
	end

     end
		end
	when 64 then
		begin
te = p+1
 begin
      emit(:literal, :literal, copy(data, ts, te))
     end
		end
	when 15 then
		begin
te = p+1
 begin
      text = copy(data, ts, te)
      emit(:literal, :literal, text)
     end
		end
	when 71 then
		begin
te = p
p = p - 1; begin
      # ranges cant start with the opening bracket, a subset, or
      # intersection/negation/range operators
      if prev_token[0] == :set
        emit(:literal, :literal, '-')
      else
        emit(:set, :range, '-')
      end
     end
		end
	when 74 then
		begin
te = p
p = p - 1; begin
      emit(:set, :open, '[')
      	begin
		stack[top] = cs
		top+= 1
		cs = 91
		_goto_level = _again
		next
	end

     end
		end
	when 69 then
		begin
te = p
p = p - 1; begin
      text = copy(data, ts, te)
      emit(:literal, :literal, text)
     end
		end
	when 16 then
		begin
 begin p = ((te))-1; end
 begin
      # ranges cant start with the opening bracket, a subset, or
      # intersection/negation/range operators
      if prev_token[0] == :set
        emit(:literal, :literal, '-')
      else
        emit(:set, :range, '-')
      end
     end
		end
	when 19 then
		begin
 begin p = ((te))-1; end
 begin
      emit(:set, :open, '[')
      	begin
		stack[top] = cs
		top+= 1
		cs = 91
		_goto_level = _again
		next
	end

     end
		end
	when 14 then
		begin
 begin p = ((te))-1; end
 begin
      text = copy(data, ts, te)
      emit(:literal, :literal, text)
     end
		end
	when 78 then
		begin
te = p+1
 begin
      emit(:escape, :octal, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 76 then
		begin
te = p+1
 begin
      p = p - 1;
      cs = 91;
      	begin
		stack[top] = cs
		top+= 1
		cs = 101
		_goto_level = _again
		next
	end

     end
		end
	when 75 then
		begin
te = p+1
 begin
      emit(:escape, :literal, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 77 then
		begin
te = p
p = p - 1; begin
      emit(:escape, :octal, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 85 then
		begin
te = p+1
 begin
      emit(:escape, :octal, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 79 then
		begin
te = p+1
 begin
      case text = copy(data, ts-1,te)
      when '\.';  emit(:escape, :dot,               text)
      when '\|';  emit(:escape, :alternation,       text)
      when '\^';  emit(:escape, :bol,               text)
      when '\$';  emit(:escape, :eol,               text)
      when '\?';  emit(:escape, :zero_or_one,       text)
      when '\*';  emit(:escape, :zero_or_more,      text)
      when '\+';  emit(:escape, :one_or_more,       text)
      when '\(';  emit(:escape, :group_open,        text)
      when '\)';  emit(:escape, :group_close,       text)
      when '\{';  emit(:escape, :interval_open,     text)
      when '\}';  emit(:escape, :interval_close,    text)
      when '\[';  emit(:escape, :set_open,          text)
      when '\]';  emit(:escape, :set_close,         text)
      when "\\\\";
        emit(:escape, :backslash, text)
      end
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 82 then
		begin
te = p+1
 begin
      # \b is emitted as backspace only when inside a character set, otherwise
      # it is a word boundary anchor. A syntax might "normalize" it if needed.
      case text = copy(data, ts-1,te)
      when '\a'; emit(:escape, :bell,           text)
      when '\b'; emit(:escape, :backspace,      text)
      when '\e'; emit(:escape, :escape,         text)
      when '\f'; emit(:escape, :form_feed,      text)
      when '\n'; emit(:escape, :newline,        text)
      when '\r'; emit(:escape, :carriage,       text)
      when '\t'; emit(:escape, :tab,            text)
      when '\v'; emit(:escape, :vertical_tab,   text)
      end
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 28 then
		begin
te = p+1
 begin
      text = copy(data, ts-1,te)
      if text[2] == '{'
        emit(:escape, :codepoint_list, text)
      else
        emit(:escape, :codepoint,      text)
      end
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 92 then
		begin
te = p+1
 begin
      emit(:escape, :hex, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 24 then
		begin
te = p+1
 begin
      emit_meta_control_sequence(data, ts, te, :control)
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 26 then
		begin
te = p+1
 begin
      emit_meta_control_sequence(data, ts, te, :meta_sequence)
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 80 then
		begin
te = p+1
 begin
      p = p - 1;
      cs = ((in_set? ? 91 : 74));
      	begin
		stack[top] = cs
		top+= 1
		cs = 89
		_goto_level = _again
		next
	end

     end
		end
	when 81 then
		begin
te = p+1
 begin
      p = p - 1;
      cs = ((in_set? ? 91 : 74));
      	begin
		stack[top] = cs
		top+= 1
		cs = 90
		_goto_level = _again
		next
	end

     end
		end
	when 22 then
		begin
te = p+1
 begin
      emit(:escape, :literal, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 86 then
		begin
te = p
p = p - 1; begin
      text = copy(data, ts-1,te)

      # If not enough groups have been opened, there is a fallback to either an
      # octal or literal interpretation for 2+ digit numerical escapes.
      digits = text[1..-1]
      if digits.size == 1 || digits.to_i <= capturing_group_count
        emit(:backref, :number, text)
      elsif digits =~ /\A[0-7]{2,}\z/
        emit(:escape, :octal, text)
      else
        emit(:escape, :literal, text[0..1])
        emit(:literal, :literal, text[2..-1])
      end

      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 84 then
		begin
te = p
p = p - 1; begin
      emit(:escape, :octal, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 93 then
		begin
te = p
p = p - 1; begin
      text = copy(data, ts-1,te)
      if regexp_encoding == Encoding::BINARY
        text.split(/(?=\\)/).each { |part| emit(:escape, :hex, part) }
      else
        emit(:escape, :utf8_hex, text)
      end
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 91 then
		begin
te = p
p = p - 1; begin
      emit(:escape, :hex, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 88 then
		begin
te = p
p = p - 1; begin
      emit_meta_control_sequence(data, ts, te, :control)
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 90 then
		begin
te = p
p = p - 1; begin
      emit_meta_control_sequence(data, ts, te, :meta_sequence)
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 83 then
		begin
te = p
p = p - 1; begin
      emit(:escape, :literal, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 30 then
		begin
 begin p = ((te))-1; end
 begin
      text = copy(data, ts-1,te)
      if regexp_encoding == Encoding::BINARY
        text.split(/(?=\\)/).each { |part| emit(:escape, :hex, part) }
      else
        emit(:escape, :utf8_hex, text)
      end
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 21 then
		begin
 begin p = ((te))-1; end
 begin
      emit(:escape, :literal, copy(data, ts-1,te))
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 33 then
		begin
te = p+1
 begin
      text = copy(data, ts, te-1)
      text =~ /[^0]/ or raise ValidationError.for(:backref, 'condition', 'invalid ref ID')
      emit(:conditional, :condition, text)
      emit(:conditional, :condition_close, ')')
     end
		end
	when 94 then
		begin
te = p+1
 begin
      p = p - 1;
      	begin
		stack[top] = cs
		top+= 1
		cs = 74
		_goto_level = _again
		next
	end

     end
		end
	when 95 then
		begin
te = p
p = p - 1; begin
      p = p - 1;
      	begin
		stack[top] = cs
		top+= 1
		cs = 74
		_goto_level = _again
		next
	end

     end
		end
	when 32 then
		begin
 begin p = ((te))-1; end
 begin
      p = p - 1;
      	begin
		stack[top] = cs
		top+= 1
		cs = 74
		_goto_level = _again
		next
	end

     end
		end
	when 39 then
		begin
te = p+1
 begin
      emit(:meta, :dot, copy(data, ts, te))
     end
		end
	when 43 then
		begin
te = p+1
 begin
      if conditional_stack.last == group_depth
        emit(:conditional, :separator, copy(data, ts, te))
      else
        emit(:meta, :alternation, copy(data, ts, te))
      end
     end
		end
	when 42 then
		begin
te = p+1
 begin
      emit(:anchor, :bol, copy(data, ts, te))
     end
		end
	when 36 then
		begin
te = p+1
 begin
      emit(:anchor, :eol, copy(data, ts, te))
     end
		end
	when 60 then
		begin
te = p+1
 begin
      emit(:keep, :mark, copy(data, ts, te))
     end
		end
	when 59 then
		begin
te = p+1
 begin
      case text = copy(data, ts, te)
      when '\A';  emit(:anchor, :bos,                text)
      when '\z';  emit(:anchor, :eos,                text)
      when '\Z';  emit(:anchor, :eos_ob_eol,         text)
      when '\b';  emit(:anchor, :word_boundary,      text)
      when '\B';  emit(:anchor, :nonword_boundary,   text)
      when '\G';  emit(:anchor, :match_start,        text)
      end
     end
		end
	when 41 then
		begin
te = p+1
 begin
      append_literal(data, ts, te)
     end
		end
	when 50 then
		begin
te = p+1
 begin
      text = copy(data, ts, te)

      conditional_stack << group_depth

      emit(:conditional, :open, text[0..-2])
      emit(:conditional, :condition_open, '(')
      	begin
		stack[top] = cs
		top+= 1
		cs = 121
		_goto_level = _again
		next
	end

     end
		end
	when 51 then
		begin
te = p+1
 begin
      text = copy(data, ts, te)
      if text[2..-1] =~ /([^\-mixdau:]|^$)|-.*([dau])/
        raise ValidationError.for(:group_option, $1 || "-#{$2}", text)
      end
      emit_options(text)
     end
		end
	when 6 then
		begin
te = p+1
 begin
      case text = copy(data, ts, te)
      when '(?=';  emit(:assertion, :lookahead,    text)
      when '(?!';  emit(:assertion, :nlookahead,   text)
      when '(?<='; emit(:assertion, :lookbehind,   text)
      when '(?<!'; emit(:assertion, :nlookbehind,  text)
      end
     end
		end
	when 5 then
		begin
te = p+1
 begin
      case text = copy(data, ts, te)
      when '(?:';  emit(:group, :passive,      text)
      when '(?>';  emit(:group, :atomic,       text)
      when '(?~';  emit(:group, :absence,      text)

      when /^\(\?(?:<>|'')/
        raise ValidationError.for(:group, 'named group', 'name is empty')

      when /^\(\?<[^>]+>/
        emit(:group, :named_ab,  text)

      when /^\(\?'[^']+'/
        emit(:group, :named_sq,  text)

      end
     end
		end
	when 9 then
		begin
te = p+1
 begin
      case text = copy(data, ts, te)
      when /^\\k(.)[^0-9\-][^+\-]*['>]$/
        emit(:backref, $1 == '<' ? :name_ref_ab : :name_ref_sq, text)
      when /^\\k(.)0*[1-9]\d*['>]$/
        emit(:backref, $1 == '<' ? :number_ref_ab : :number_ref_sq, text)
      when /^\\k(.)-0*[1-9]\d*['>]$/
        emit(:backref, $1 == '<' ? :number_rel_ref_ab : :number_rel_ref_sq, text)
      when /^\\k(.)[^0-9\-].*[+\-]\d+['>]$/
        emit(:backref, $1 == '<' ? :name_recursion_ref_ab : :name_recursion_ref_sq, text)
      when /^\\k(.)-?0*[1-9]\d*[+\-]\d+['>]$/
        emit(:backref, $1 == '<' ? :number_recursion_ref_ab : :number_recursion_ref_sq, text)
      else
        raise ValidationError.for(:backref, 'backreference', 'invalid ref ID')
      end
     end
		end
	when 8 then
		begin
te = p+1
 begin
      case text = copy(data, ts, te)
      when /^\\g(.)[^0-9+\-].*['>]$/
        emit(:backref, $1 == '<' ? :name_call_ab : :name_call_sq, text)
      when /^\\g(.)(?:0|0*[1-9]\d*)['>]$/
        emit(:backref, $1 == '<' ? :number_call_ab : :number_call_sq, text)
      when /^\\g(.)[+-]0*[1-9]\d*/
        emit(:backref, $1 == '<' ? :number_rel_call_ab : :number_rel_call_sq, text)
      else
        raise ValidationError.for(:backref, 'subexpression call', 'invalid ref ID')
      end
     end
		end
	when 57 then
		begin
te = p+1
 begin
      case text = copy(data, ts, te)
      when '?' ;  emit(:quantifier, :zero_or_one,            text)
      when '??';  emit(:quantifier, :zero_or_one_reluctant,  text)
      when '?+';  emit(:quantifier, :zero_or_one_possessive, text)
      end
     end
		end
	when 53 then
		begin
te = p+1
 begin
      case text = copy(data, ts, te)
      when '*' ;  emit(:quantifier, :zero_or_more,            text)
      when '*?';  emit(:quantifier, :zero_or_more_reluctant,  text)
      when '*+';  emit(:quantifier, :zero_or_more_possessive, text)
      end
     end
		end
	when 55 then
		begin
te = p+1
 begin
      case text = copy(data, ts, te)
      when '+' ;  emit(:quantifier, :one_or_more,            text)
      when '+?';  emit(:quantifier, :one_or_more_reluctant,  text)
      when '++';  emit(:quantifier, :one_or_more_possessive, text)
      end
     end
		end
	when 11 then
		begin
te = p+1
 begin
      emit(:quantifier, :interval, copy(data, ts, te))
     end
		end
	when 47 then
		begin
te = p+1
 begin
      if free_spacing
        emit(:free_space, :comment, copy(data, ts, te))
      else
        # consume only the pound sign (#) and backtrack to do regular scanning
        append_literal(data, ts, ts + 1)
         begin p = (( ts + 1))-1; end

      end
     end
		end
	when 49 then
		begin
te = p
p = p - 1; begin
      text = copy(data, ts, te)
      if text[2..-1] =~ /([^\-mixdau:]|^$)|-.*([dau])/
        raise ValidationError.for(:group_option, $1 || "-#{$2}", text)
      end
      emit_options(text)
     end
		end
	when 48 then
		begin
te = p
p = p - 1; begin
      self.capturing_group_count = capturing_group_count + 1
      text = copy(data, ts, te)
      emit(:group, :capture, text)
     end
		end
	when 56 then
		begin
te = p
p = p - 1; begin
      case text = copy(data, ts, te)
      when '?' ;  emit(:quantifier, :zero_or_one,            text)
      when '??';  emit(:quantifier, :zero_or_one_reluctant,  text)
      when '?+';  emit(:quantifier, :zero_or_one_possessive, text)
      end
     end
		end
	when 52 then
		begin
te = p
p = p - 1; begin
      case text = copy(data, ts, te)
      when '*' ;  emit(:quantifier, :zero_or_more,            text)
      when '*?';  emit(:quantifier, :zero_or_more_reluctant,  text)
      when '*+';  emit(:quantifier, :zero_or_more_possessive, text)
      end
     end
		end
	when 54 then
		begin
te = p
p = p - 1; begin
      case text = copy(data, ts, te)
      when '+' ;  emit(:quantifier, :one_or_more,            text)
      when '+?';  emit(:quantifier, :one_or_more_reluctant,  text)
      when '++';  emit(:quantifier, :one_or_more_possessive, text)
      end
     end
		end
	when 61 then
		begin
te = p
p = p - 1; begin
      append_literal(data, ts, te)
     end
		end
	when 58 then
		begin
te = p
p = p - 1; begin
      	begin
		stack[top] = cs
		top+= 1
		cs = 101
		_goto_level = _again
		next
	end

     end
		end
	when 46 then
		begin
te = p
p = p - 1; begin
      if free_spacing
        emit(:free_space, :comment, copy(data, ts, te))
      else
        # consume only the pound sign (#) and backtrack to do regular scanning
        append_literal(data, ts, ts + 1)
         begin p = (( ts + 1))-1; end

      end
     end
		end
	when 45 then
		begin
te = p
p = p - 1; begin
      if free_spacing
        emit(:free_space, :whitespace, copy(data, ts, te))
      else
        append_literal(data, ts, te)
      end
     end
		end
	when 44 then
		begin
te = p
p = p - 1; begin
      append_literal(data, ts, te)
     end
		end
	when 3 then
		begin
 begin p = ((te))-1; end
 begin
      text = copy(data, ts, te)
      if text[2..-1] =~ /([^\-mixdau:]|^$)|-.*([dau])/
        raise ValidationError.for(:group_option, $1 || "-#{$2}", text)
      end
      emit_options(text)
     end
		end
	when 10 then
		begin
 begin p = ((te))-1; end
 begin
      append_literal(data, ts, te)
     end
		end
	when 7 then
		begin
 begin p = ((te))-1; end
 begin
      	begin
		stack[top] = cs
		top+= 1
		cs = 101
		_goto_level = _again
		next
	end

     end
		end
	when 1 then
		begin
	case act
	when 0 then
	begin	begin
		cs = 0
		_goto_level = _again
		next
	end
end
	when 58 then
	begin begin p = ((te))-1; end

      append_literal(data, ts, te)
    end
end
			end
	when 73 then
		begin

    text = copy(data, ts ? ts-1 : 0,-1)
    raise PrematureEndError.new(text)
  		end
		begin
te = p
p = p - 1; begin
      emit(:set, :open, '[')
      	begin
		stack[top] = cs
		top+= 1
		cs = 91
		_goto_level = _again
		next
	end

     end
		end
	when 18 then
		begin

    text = copy(data, ts ? ts-1 : 0,-1)
    raise PrematureEndError.new(text)
  		end
		begin
 begin p = ((te))-1; end
 begin
      emit(:set, :open, '[')
      	begin
		stack[top] = cs
		top+= 1
		cs = 91
		_goto_level = _again
		next
	end

     end
		end
	when 87 then
		begin

    text = copy(data, ts ? ts-1 : 0,-1)
    raise PrematureEndError.new(text)
  		end
		begin
te = p
p = p - 1; begin
      emit_meta_control_sequence(data, ts, te, :control)
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 89 then
		begin

    text = copy(data, ts ? ts-1 : 0,-1)
    raise PrematureEndError.new(text)
  		end
		begin
te = p
p = p - 1; begin
      emit_meta_control_sequence(data, ts, te, :meta_sequence)
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 25 then
		begin

    text = copy(data, ts ? ts-1 : 0,-1)
    raise PrematureEndError.new(text)
  		end
		begin
 begin p = ((te))-1; end
 begin
      emit_meta_control_sequence(data, ts, te, :control)
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 27 then
		begin

    text = copy(data, ts ? ts-1 : 0,-1)
    raise PrematureEndError.new(text)
  		end
		begin
 begin p = ((te))-1; end
 begin
      emit_meta_control_sequence(data, ts, te, :meta_sequence)
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 29 then
		begin

    text = copy(data, ts ? ts-1 : 0,-1)
    raise ValidationError.for(:sequence, 'sequence', text)
  		end
		begin
te = p+1
 begin
      	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

     end
		end
	when 4 then
		begin
 self.group_depth = group_depth - 1 		end
		begin
te = p+1
 begin
      emit(:group, :comment, copy(data, ts, te))
     end
		end
	when 38 then
		begin
 self.group_depth = group_depth - 1 		end
		begin
te = p+1
 begin
      if conditional_stack.last == group_depth + 1
        conditional_stack.pop
        emit(:conditional, :close, ')')
      elsif group_depth >= 0
        if spacing_stack.length > 1 &&
           spacing_stack.last[:depth] == group_depth + 1
          spacing_stack.pop
          self.free_spacing = spacing_stack.last[:free_spacing]
        end

        emit(:group, :close, ')')
      else
        raise ValidationError.for(:group, 'group', 'unmatched close parenthesis')
      end
     end
		end
	when 40 then
		begin
 self.set_depth   = set_depth   + 1 		end
		begin
te = p+1
 begin
      emit(:set, :open, copy(data, ts, te))
      	begin
		stack[top] = cs
		top+= 1
		cs = 91
		_goto_level = _again
		next
	end

     end
		end
	when 67 then
		begin
 self.set_depth   = set_depth   - 1 		end
		begin
te = p+1
 begin
      emit(:set, :close, copy(data, ts, te))
      if in_set?
        	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

      else
        	begin
		cs = 74
		_goto_level = _again
		next
	end

      end
     end
		end
	when 72 then
		begin
 self.set_depth   = set_depth   - 1 		end
		begin
te = p+1
 begin  # special case, emits two tokens
      emit(:literal, :literal, '-')
      emit(:set, :close, ']')
      if in_set?
        	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end

      else
        	begin
		cs = 74
		_goto_level = _again
		next
	end

      end
     end
		end
	when 20 then
		begin
 self.set_depth   = set_depth   - 1 		end
		begin
te = p+1
 begin
      text = copy(data, ts, te)

      type = :posixclass
      class_name = text[2..-3]
      if class_name[0] == '^'
        class_name = class_name[1..-1]
        type = :nonposixclass
      end

      unless POSIX_CLASSES[class_name]
        raise ValidationError.for(:posix_class, text)
      end

      emit(type, class_name.to_sym, text)
     end
		end
	when 65 then
		begin
te = p+1
		end
		begin
 self.set_depth   = set_depth   + 1 		end
	when 2 then
		begin
te = p+1
		end
		begin
act = 58;		end
	end
	end
	end
	if _goto_level <= _again
	case _re_scanner_to_state_actions[cs]
	when 62 then
		begin
ts = nil;		end
	when 34 then
		begin
ts = nil;		end
		begin
act = 0
		end
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
	if _re_scanner_eof_trans[cs] > 0
		_trans = _re_scanner_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
	  case _re_scanner_eof_actions[cs]
	when 12 then
		begin

    raise PrematureEndError.new('unicode property')
  		end
	when 23 then
		begin

    text = copy(data, ts ? ts-1 : 0,-1)
    raise PrematureEndError.new(text)
  		end
	  end
	end

	end
	if _goto_level <= _out
		break
	end
end
	end

    # to avoid "warning: assigned but unused variable - testEof"
    testEof = testEof

    if cs == re_scanner_error
      text = copy(data, ts ? ts-1 : 0,-1)
      raise ScannerError.new("Scan error at '#{text}'")
    end

    raise PrematureEndError.new("(missing group closing paranthesis) "+
          "[#{group_depth}]") if in_group?
    raise PrematureEndError.new("(missing set closing bracket) "+
          "[#{set_depth}]") if in_set?

    # when the entire expression is a literal run
    emit_literal if literal_run

    tokens
  end

  # lazy-load property maps when first needed
  def self.short_prop_map
    @short_prop_map ||= parse_prop_map('short')
  end

  def self.long_prop_map
    @long_prop_map ||= parse_prop_map('long')
  end

  def self.parse_prop_map(name)
    File.read("#{__dir__}/scanner/properties/#{name}.csv").scan(/(.+),(.+)/).to_h
  end

  # Use each_with_object for required_ruby_version >= 2.2,or #to_h for >= 2.6
  POSIX_CLASSES =
    %w[alnum alpha ascii blank cntrl digit graph
       lower print punct space upper word xdigit]
      .inject({}) { |o, e| o.merge(e => true) }.freeze

  # Emits an array with the details of the scanned pattern
  def emit(type, token, text)
    #puts "EMIT: type: #{type}, token: #{token}, text: #{text}, ts: #{ts}, te: #{te}"

    emit_literal if literal_run

    # Ragel runs with byte-based indices (ts, te). These are of little value to
    # end-users, so we keep track of char-based indices and emit those instead.
    ts_char_pos = char_pos
    te_char_pos = char_pos + text.length

    tok = [type, token, text, ts_char_pos, te_char_pos]

    self.prev_token = tok

    self.char_pos = te_char_pos

    if block
      block.call type, token, text, ts_char_pos, te_char_pos
      # TODO: in v3.0.0,remove `collect_tokens:` kwarg and only collect if no block given
      tokens << tok if collect_tokens
    elsif collect_tokens
      tokens << tok
    end
  end

  attr_accessor :capturing_group_count, :literal_run # only public for #||= to work on ruby <= 2.5

  private

  attr_accessor :block,
                :collect_tokens, :tokens, :prev_token,
                :free_spacing, :spacing_stack,
                :regexp_encoding,
                :group_depth, :set_depth, :conditional_stack,
                :char_pos

  def extract_encoding(input_object, options)
    if input_object.is_a?(::Regexp)
      input_object.encoding
    elsif options && (options & Regexp::NOENCODING)
      Encoding::BINARY
    end
  end

  def free_spacing?(input_object, options)
    if options && !input_object.is_a?(String)
      raise ArgumentError, 'options cannot be supplied unless scanning a String'
    end

    options = input_object.options if input_object.is_a?(::Regexp)

    return false unless options

    options & Regexp::EXTENDED != 0
  end

  def in_group?
    group_depth > 0
  end

  def in_set?
    set_depth > 0
  end

  # Copy from ts to te from data as text
  def copy(data, ts, te)
    data[ts...te].pack('c*').force_encoding('utf-8')
  end

  # Appends one or more characters to the literal buffer, to be emitted later
  # by a call to emit_literal.
  def append_literal(data, ts, te)
    (self.literal_run ||= []) << copy(data, ts, te)
  end

  # Emits the literal run collected by calls to the append_literal method.
  def emit_literal
    text = literal_run.join
    self.literal_run = nil
    emit(:literal, :literal, text)
  end

  def emit_options(text)
    token = nil

    # Ruby allows things like '(?-xxxx)' or '(?xx-xx--xx-:abc)'.
    text =~ /\(\?([mixdau]*)(-(?:[mix]*))*(:)?/
    positive, negative, group_local = $1,$2,$3

    if positive.include?('x')
      self.free_spacing = true
    end

    # If the x appears in both, treat it like ruby does, the second cancels
    # the first.
    if negative && negative.include?('x')
      self.free_spacing = false
    end

    if group_local
      spacing_stack << {:free_spacing => free_spacing, :depth => group_depth}
      token = :options
    else
      # switch for parent group level
      spacing_stack.last[:free_spacing] = free_spacing
      token = :options_switch
    end

    emit(:group, token, text)
  end

  def emit_meta_control_sequence(data, ts, te, token)
    if data.last < 0x00 || data.last > 0x7F
      raise ValidationError.for(:sequence, 'escape', token.to_s)
    end
    emit(:escape, token, copy(data, ts-1,te))
  end
end # module Regexp::Scanner
