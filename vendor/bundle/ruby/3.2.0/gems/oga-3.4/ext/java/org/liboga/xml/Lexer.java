
// line 1 "ext/java/org/liboga/xml/Lexer.rl"
package org.liboga.xml;


// line 4 "ext/java/org/liboga/xml/Lexer.rl"

import java.io.IOException;

import org.jcodings.Encoding;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyString;
import org.jruby.RubyFixnum;
import org.jruby.util.ByteList;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.builtin.IRubyObject;

/**
 * Lexer support class for JRuby.
 *
 * The Lexer class contains the raw Ragel loop and calls back in to Ruby land
 * whenever a Ragel action is needed similar to the C extension setup.
 *
 * This class requires Ruby land to first define the `Oga::XML` namespace.
 */
@JRubyClass(name="Oga::XML::Lexer", parent="Object")
public class Lexer extends RubyObject
{
    /**
     * The current Ruby runtime.
     */
    private Ruby runtime;

    
// line 43 "ext/java/org/liboga/xml/Lexer.java"
private static byte[] init__java_lexer_actions_0()
{
	return new byte [] {
	    0,    1,    0,    1,    2,    1,    3,    1,    4,    1,    5,    1,
	    6,    1,    7,    1,    8,    1,    9,    1,   10,    1,   11,    1,
	   12,    1,   13,    1,   14,    1,   15,    1,   16,    1,   17,    1,
	   18,    1,   21,    1,   22,    1,   23,    1,   24,    1,   25,    1,
	   26,    1,   27,    1,   28,    1,   29,    1,   30,    1,   34,    1,
	   35,    1,   36,    1,   37,    1,   38,    1,   41,    1,   43,    1,
	   44,    1,   45,    1,   46,    1,   47,    1,   48,    1,   49,    1,
	   50,    1,   51,    1,   52,    1,   53,    1,   54,    1,   55,    1,
	   56,    1,   57,    1,   58,    1,   59,    1,   60,    1,   61,    1,
	   62,    1,   63,    1,   64,    1,   65,    1,   66,    1,   67,    1,
	   68,    1,   69,    1,   70,    1,   71,    1,   72,    1,   73,    1,
	   74,    1,   75,    1,   76,    1,   77,    1,   78,    1,   79,    1,
	   80,    1,   83,    1,   84,    1,   85,    1,   86,    1,   87,    1,
	   88,    1,   89,    1,   90,    1,   91,    1,   92,    2,    0,    1,
	    2,    0,   33,    2,    0,   40,    2,    0,   42,    2,    4,    0,
	    2,    4,   19,    2,    4,   20,    2,    4,   81,    2,    4,   82,
	    2,   31,    0,    2,   32,    0,    2,   39,    0
	};
}

private static final byte _java_lexer_actions[] = init__java_lexer_actions_0();


private static short[] init__java_lexer_key_offsets_0()
{
	return new short [] {
	    0,    0,    4,    5,    7,    9,   11,   13,   15,   17,   21,   22,
	   23,   24,   25,   26,   27,   38,   48,   49,   50,   60,   70,   71,
	   72,   73,   74,   75,   76,   77,   78,   79,   80,   81,   82,   83,
	   84,   96,  100,  111,  121,  133,  145,  146,  147,  148,  149,  150,
	  151,  152,  153,  154,  155,  156,  157,  158,  159,  160,  182,  183,
	  193,  205,  217,  229,  241,  253,  265,  277,  289,  301,  313,  326,
	  336,  337,  347,  358,  369,  380,  386,  387,  392,  397,  399,  414,
	  415,  426,  427,  437,  448,  458,  473,  474,  484,  485,  495,  506,
	  516,  517,  518,  531,  544,  545,  546,  548,  549,  550,  551,  553
	};
}

private static final short _java_lexer_key_offsets[] = init__java_lexer_key_offsets_0();


private static char[] init__java_lexer_trans_keys_0()
{
	return new char [] {
	   45,   68,   91,  100,   45,   79,  111,   67,   99,   84,  116,   89,
	  121,   80,  112,   69,  101,   13,   32,    9,   10,   67,   68,   65,
	   84,   65,   91,   47,   96,  120,    0,   44,   58,   64,   91,   94,
	  123,  127,   47,   96,    0,   44,   58,   64,   91,   94,  123,  127,
	   62,   62,   47,   96,    0,   44,   58,   64,   91,   94,  123,  127,
	   47,   96,    0,   44,   58,   64,   91,   94,  123,  127,  115,   99,
	  114,  105,  112,  116,   62,  115,  116,  121,  108,  101,   62,   60,
	   33,   47,   63,   96,    0,   44,   58,   64,   91,   94,  123,  127,
	   13,   32,    9,   10,   47,   58,   96,    0,   44,   59,   64,   91,
	   94,  123,  127,   47,   96,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   58,   96,  109,    0,   44,   59,   64,   91,   94,  123,
	  127,   47,   58,   96,  108,    0,   44,   59,   64,   91,   94,  123,
	  127,   45,   45,   45,   93,   93,   93,   63,   63,   62,   39,   39,
	   34,   34,   93,   93,    9,   10,   13,   32,   34,   39,   47,   62,
	   80,   83,   91,   96,  112,  115,    0,   44,   58,   64,   92,   94,
	  123,  127,   10,   47,   96,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   85,   96,  117,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   66,   96,   98,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   76,   96,  108,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   73,   96,  105,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   67,   96,   99,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   89,   96,  121,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   83,   96,  115,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   84,   96,  116,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   69,   96,  101,    0,   44,   58,   64,   91,   94,  123,
	  127,   47,   77,   96,  109,    0,   44,   58,   64,   91,   94,  123,
	  127,   34,   39,   47,   63,   96,    0,   44,   58,   64,   91,   94,
	  123,  127,   47,   96,    0,   44,   58,   64,   91,   94,  123,  127,
	   62,   47,   96,    0,   44,   58,   64,   91,   94,  123,  127,   47,
	   58,   96,    0,   44,   59,   64,   91,   94,  123,  127,   47,   62,
	   96,    0,   44,   58,   64,   91,   94,  123,  127,   47,   58,   96,
	    0,   44,   59,   64,   91,   94,  123,  127,   13,   32,   34,   39,
	    9,   10,   10,   13,   32,   62,    9,   10,   13,   32,   62,    9,
	   10,   34,   39,   10,   13,   47,   60,   61,   62,   96,    0,   44,
	   58,   64,   91,   94,  123,  127,   10,   47,   58,   96,    0,   44,
	   59,   64,   91,   94,  123,  127,   62,   47,   96,    0,   44,   58,
	   64,   91,   94,  123,  127,   47,   58,   96,    0,   44,   59,   64,
	   91,   94,  123,  127,   47,   96,    0,   44,   58,   64,   91,   94,
	  123,  127,   10,   13,   47,   60,   61,   62,   96,    0,   44,   59,
	   64,   91,   94,  123,  127,   10,   47,   96,    0,   44,   59,   64,
	   91,   94,  123,  127,   62,   47,   96,    0,   44,   58,   64,   91,
	   94,  123,  127,   47,   58,   96,    0,   44,   59,   64,   91,   94,
	  123,  127,   47,   96,    0,   44,   58,   64,   91,   94,  123,  127,
	   60,   60,   60,   64,   96,    0,   32,   34,   44,   58,   62,   91,
	   94,  123,  127,   60,   64,   96,    0,   32,   34,   44,   58,   62,
	   91,   94,  123,  127,   60,   60,   47,   60,   60,   60,   60,   47,
	   60,   60,    0
	};
}

private static final char _java_lexer_trans_keys[] = init__java_lexer_trans_keys_0();


private static byte[] init__java_lexer_single_lengths_0()
{
	return new byte [] {
	    0,    4,    1,    2,    2,    2,    2,    2,    2,    2,    1,    1,
	    1,    1,    1,    1,    3,    2,    1,    1,    2,    2,    1,    1,
	    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
	    4,    2,    3,    2,    4,    4,    1,    1,    1,    1,    1,    1,
	    1,    1,    1,    1,    1,    1,    1,    1,    1,   14,    1,    2,
	    4,    4,    4,    4,    4,    4,    4,    4,    4,    4,    5,    2,
	    1,    2,    3,    3,    3,    4,    1,    3,    3,    2,    7,    1,
	    3,    1,    2,    3,    2,    7,    1,    2,    1,    2,    3,    2,
	    1,    1,    3,    3,    1,    1,    2,    1,    1,    1,    2,    1
	};
}

private static final byte _java_lexer_single_lengths[] = init__java_lexer_single_lengths_0();


private static byte[] init__java_lexer_range_lengths_0()
{
	return new byte [] {
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    1,    0,    0,
	    0,    0,    0,    0,    4,    4,    0,    0,    4,    4,    0,    0,
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
	    4,    1,    4,    4,    4,    4,    0,    0,    0,    0,    0,    0,
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    4,    0,    4,
	    4,    4,    4,    4,    4,    4,    4,    4,    4,    4,    4,    4,
	    0,    4,    4,    4,    4,    1,    0,    1,    1,    0,    4,    0,
	    4,    0,    4,    4,    4,    4,    0,    4,    0,    4,    4,    4,
	    0,    0,    5,    5,    0,    0,    0,    0,    0,    0,    0,    0
	};
}

private static final byte _java_lexer_range_lengths[] = init__java_lexer_range_lengths_0();


private static short[] init__java_lexer_index_offsets_0()
{
	return new short [] {
	    0,    0,    5,    7,   10,   13,   16,   19,   22,   25,   29,   31,
	   33,   35,   37,   39,   41,   49,   56,   58,   60,   67,   74,   76,
	   78,   80,   82,   84,   86,   88,   90,   92,   94,   96,   98,  100,
	  102,  111,  115,  123,  130,  139,  148,  150,  152,  154,  156,  158,
	  160,  162,  164,  166,  168,  170,  172,  174,  176,  178,  197,  199,
	  206,  215,  224,  233,  242,  251,  260,  269,  278,  287,  296,  306,
	  313,  315,  322,  330,  338,  346,  352,  354,  359,  364,  367,  379,
	  381,  389,  391,  398,  406,  413,  425,  427,  434,  436,  443,  451,
	  458,  460,  462,  471,  480,  482,  484,  487,  489,  491,  493,  496
	};
}

private static final short _java_lexer_index_offsets[] = init__java_lexer_index_offsets_0();


private static byte[] init__java_lexer_trans_targs_0()
{
	return new byte [] {
	    2,    3,   10,    3,   35,   35,   35,    4,    4,   35,    5,    5,
	   35,    6,    6,   35,    7,    7,   35,    8,    8,   35,    9,    9,
	   35,   37,   37,   37,   35,   11,   35,   12,   35,   13,   35,   14,
	   35,   15,   35,   35,   35,   35,   35,   40,   35,   35,   35,   35,
	   38,   35,   35,   35,   35,   35,   35,   39,   42,   42,   45,   45,
	   82,   82,   82,   82,   82,   82,   88,   89,   89,   89,   89,   89,
	   89,   95,   23,  100,   24,  100,   25,  100,   26,  100,   27,  100,
	   28,  100,  100,  100,   30,  104,   31,  104,   32,  104,   33,  104,
	   34,  104,  104,  104,   36,   35,    1,   35,   16,   35,   35,   35,
	   35,   35,   35,   37,   37,   37,   35,   35,   17,   35,   35,   35,
	   35,   35,   38,   35,   35,   35,   35,   35,   35,   39,   35,   17,
	   35,   41,   35,   35,   35,   35,   38,   35,   17,   35,   38,   35,
	   35,   35,   35,   38,   44,   43,   42,   43,   18,   42,   47,   46,
	   45,   46,   19,   45,   50,   49,   48,   49,   48,   48,   51,   52,
	   51,   52,   53,   54,   53,   54,   55,   56,   55,   56,   57,   57,
	   58,   57,   57,   57,    0,   57,   60,   65,   57,    0,   60,   65,
	    0,    0,    0,    0,   59,   57,   57,   57,   57,   57,   57,   57,
	   57,   59,   57,   61,   57,   61,   57,   57,   57,   57,   59,   57,
	   62,   57,   62,   57,   57,   57,   57,   59,   57,   63,   57,   63,
	   57,   57,   57,   57,   59,   57,   64,   57,   64,   57,   57,   57,
	   57,   59,   57,   59,   57,   59,   57,   57,   57,   57,   59,   57,
	   66,   57,   66,   57,   57,   57,   57,   59,   57,   67,   57,   67,
	   57,   57,   57,   57,   59,   57,   68,   57,   68,   57,   57,   57,
	   57,   59,   57,   69,   57,   69,   57,   57,   57,   57,   59,   57,
	   59,   57,   59,   57,   57,   57,   57,   59,   70,   70,   70,   72,
	   70,   70,   70,   70,   70,   71,   70,   70,   70,   70,   70,   70,
	   71,   70,   70,    0,    0,    0,    0,    0,    0,   74,   73,   73,
	   73,   73,   73,   73,   73,   74,   75,   75,   75,   75,   75,   75,
	   75,   76,   75,   75,   75,   75,   75,   75,   75,   76,   78,   77,
	   77,   77,   77,   77,   77,   77,   79,   79,   79,   79,   80,   79,
	   79,   79,   79,   80,   81,   81,   81,   82,   83,   85,   86,   82,
	   82,   82,   82,   82,   82,   82,   84,   82,   82,   82,   82,   82,
	   82,   82,   82,   82,   84,   82,   82,   82,   82,   82,   82,   82,
	   82,   87,   82,   20,   82,   82,   82,   82,   82,   87,   82,   82,
	   82,   82,   82,   82,   88,   89,   90,   92,   93,   89,   89,   89,
	   89,   89,   89,   89,   91,   89,   89,   89,   89,   89,   89,   89,
	   89,   91,   89,   89,   89,   89,   89,   89,   89,   89,   94,   89,
	   21,   89,   89,   89,   89,   89,   94,   89,   89,   89,   89,   89,
	   89,   95,   99,   97,   98,   97,   98,   97,   97,   97,   97,   97,
	   97,   97,   96,   98,   97,   97,   97,   97,   97,   97,   97,   96,
	  102,  101,  100,  101,   22,  103,  100,  103,  100,  106,  105,  104,
	  105,   29,  107,  104,  107,  104,   35,   35,   35,   35,   35,   35,
	   35,   35,   35,   35,   35,   35,   35,   35,   35,   35,   35,   42,
	   45,   82,   89,  100,  100,  100,  100,  100,  100,  100,  104,  104,
	  104,  104,  104,  104,   35,   35,   35,   35,   35,   35,   42,   42,
	   45,   45,   48,   48,   51,   53,   55,   57,   57,   57,   57,   57,
	   57,   57,   57,   57,   57,   57,   57,   70,   70,   73,   75,   77,
	   79,   82,   82,   82,   82,   82,   82,   89,   89,   89,   89,   89,
	   89,   96,   96,   96,  100,  100,  100,  104,  104,  104,    0
	};
}

private static final byte _java_lexer_trans_targs[] = init__java_lexer_trans_targs_0();


private static short[] init__java_lexer_trans_actions_0()
{
	return new short [] {
	    0,    0,    0,    0,  161,  145,  161,    0,    0,  161,    0,    0,
	  161,    0,    0,  161,    0,    0,  161,    0,    0,  161,    0,    0,
	  161,    1,    1,    1,  161,    0,  161,    0,  161,    0,  161,    0,
	  161,    0,  161,  147,  161,  161,  161,  189,  161,  161,  161,  161,
	  189,  163,  163,  163,  163,  163,  163,    0,    9,   13,   15,   19,
	  105,  105,  105,  105,  105,  105,    0,  125,  125,  125,  125,  125,
	  125,    0,    0,  137,    0,  137,    0,  137,    0,  137,    0,  137,
	    0,  137,  133,  137,    0,  143,    0,  143,    0,  143,    0,  143,
	    0,  143,  139,  143,    7,  153,    0,  151,    0,  159,  159,  159,
	  159,  159,  149,    1,    1,    1,  155,  163,    0,  163,  163,  163,
	  163,  163,  189,  157,  157,  157,  157,  157,  157,    0,  157,    0,
	  157,  189,  157,  157,  157,  157,  189,  157,    0,  157,  186,  157,
	  157,  157,  157,  189,  177,    1,   11,    1,    0,   11,  177,    1,
	   17,    1,    0,   17,    1,    1,   23,    1,   21,   23,   25,    1,
	   27,    1,   29,    1,   31,    1,   33,    1,   35,    1,   47,   45,
	    0,   47,   41,   39,    0,   43,    0,    0,   37,    0,    0,    0,
	    0,    0,    0,    0,  183,   45,   51,   53,   53,   53,   53,   53,
	   53,  183,   49,    0,   49,    0,   49,   49,   49,   49,  183,   49,
	    0,   49,    0,   49,   49,   49,   49,  183,   49,    0,   49,    0,
	   49,   49,   49,   49,  183,   49,    0,   49,    0,   49,   49,   49,
	   49,  183,   49,  180,   49,  180,   49,   49,   49,   49,  183,   49,
	    0,   49,    0,   49,   49,   49,   49,  183,   49,    0,   49,    0,
	   49,   49,   49,   49,  183,   49,    0,   49,    0,   49,   49,   49,
	   49,  183,   49,    0,   49,    0,   49,   49,   49,   49,  183,   49,
	  180,   49,  180,   49,   49,   49,   49,  183,  195,  192,  168,    1,
	  168,  168,  168,  168,  168,    1,   57,   57,   57,   57,   57,   57,
	    0,   55,   59,    0,    0,    0,    0,    0,    0,    0,   63,   61,
	   63,   63,   63,   63,   63,    0,  171,  198,  171,  171,  171,  171,
	  171,    1,   67,   65,   67,   67,   67,   67,   67,    0,    1,  174,
	   69,   69,  174,   71,  174,   73,   75,   75,   75,   75,    0,   77,
	   77,   77,   77,    0,   81,   79,   83,   85,    0,    0,    0,   89,
	   91,   95,   95,   95,   95,   95,    0,   85,   97,  101,   87,  101,
	  101,  101,  101,  101,    0,   93,  103,  103,  103,  103,  103,  103,
	  103,    7,   99,    0,   99,   99,   99,   99,   99,    7,   99,   99,
	   99,   99,   99,   99,    0,  107,    0,    0,    0,  109,  111,  115,
	  115,  115,  115,  115,    0,  107,  117,  121,  121,  121,  121,  121,
	  121,    0,  113,  123,  123,  123,  123,  123,  123,  123,    7,  119,
	    0,  119,  119,  119,  119,  119,    7,  119,  119,  119,  119,  119,
	  119,    0,  165,    1,  165,    1,  165,    1,    1,    1,    1,    1,
	    1,    1,  129,  165,    1,    1,    1,    1,    1,    1,    1,  127,
	  177,    1,  135,    1,    0,    1,  135,    1,  135,  177,    1,  141,
	    1,    0,    1,  141,    1,  141,  161,  161,  161,  161,  161,  161,
	  161,  161,  161,  161,  161,  161,  161,  161,  161,  161,  163,   13,
	   19,  105,  125,  137,  137,  137,  137,  137,  137,  137,  143,  143,
	  143,  143,  143,  143,  159,  155,  163,  157,  157,  157,   11,   11,
	   17,   17,   23,   23,   27,   31,   35,   51,   53,   49,   49,   49,
	   49,   49,   49,   49,   49,   49,   49,   57,   59,   63,   67,   73,
	   77,   97,  101,  103,  103,   99,   99,  117,  121,  123,  123,  119,
	  119,  131,  131,  131,  135,  135,  135,  141,  141,  141,    0
	};
}

private static final short _java_lexer_trans_actions[] = init__java_lexer_trans_actions_0();


private static short[] init__java_lexer_to_state_actions_0()
{
	return new short [] {
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    3,
	    0,    0,    0,    0,    0,    0,    3,    0,    0,    3,    0,    0,
	    3,    0,    0,    3,    0,    3,    0,    3,    0,    3,    0,    0,
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    3,    0,
	    0,    3,    0,    3,    0,    3,    0,    3,    0,    3,    3,    0,
	    0,    0,    0,    0,    0,    3,    0,    0,    0,    0,    0,    0,
	    3,    0,    0,    0,    3,    0,    0,    0,    3,    0,    0,    0
	};
}

private static final short _java_lexer_to_state_actions[] = init__java_lexer_to_state_actions_0();


private static short[] init__java_lexer_from_state_actions_0()
{
	return new short [] {
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    5,
	    0,    0,    0,    0,    0,    0,    5,    0,    0,    5,    0,    0,
	    5,    0,    0,    5,    0,    5,    0,    5,    0,    5,    0,    0,
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    5,    0,
	    0,    5,    0,    5,    0,    5,    0,    5,    0,    5,    5,    0,
	    0,    0,    0,    0,    0,    5,    0,    0,    0,    0,    0,    0,
	    5,    0,    0,    0,    5,    0,    0,    0,    5,    0,    0,    0
	};
}

private static final short _java_lexer_from_state_actions[] = init__java_lexer_from_state_actions_0();


private static short[] init__java_lexer_eof_trans_0()
{
	return new short [] {
	    0,  514,  514,  514,  514,  514,  514,  514,  514,  514,  514,  514,
	  514,  514,  514,  514,  514,  535,  516,  517,  518,  519,  526,  526,
	  526,  526,  526,  526,  526,  532,  532,  532,  532,  532,  532,    0,
	  533,  534,  535,  538,  538,  538,    0,  540,  540,    0,  542,  542,
	    0,  544,  544,    0,  545,    0,  546,    0,  547,    0,  548,  549,
	  559,  559,  559,  559,  559,  559,  559,  559,  559,  559,    0,  560,
	  561,    0,  562,    0,  563,    0,  564,    0,  565,    0,    0,  566,
	  567,  569,  569,  571,  571,    0,  572,  573,  575,  575,  577,  577,
	    0,  580,  580,  580,    0,  583,  583,  583,    0,  586,  586,  586
	};
}

private static final short _java_lexer_eof_trans[] = init__java_lexer_eof_trans_0();


static final int java_lexer_start = 35;
static final int java_lexer_first_final = 35;
static final int java_lexer_error = 0;

static final int java_lexer_en_comment_body = 42;
static final int java_lexer_en_cdata_body = 45;
static final int java_lexer_en_proc_ins_body = 48;
static final int java_lexer_en_string_squote = 51;
static final int java_lexer_en_string_dquote = 53;
static final int java_lexer_en_doctype_inline = 55;
static final int java_lexer_en_doctype = 57;
static final int java_lexer_en_xml_decl = 70;
static final int java_lexer_en_element_name = 73;
static final int java_lexer_en_element_close = 75;
static final int java_lexer_en_attribute_pre = 77;
static final int java_lexer_en_unquoted_attribute_value = 79;
static final int java_lexer_en_quoted_attribute_value = 81;
static final int java_lexer_en_element_head = 82;
static final int java_lexer_en_html_element_head = 89;
static final int java_lexer_en_text = 96;
static final int java_lexer_en_html_script = 100;
static final int java_lexer_en_html_style = 104;
static final int java_lexer_en_main = 35;


// line 39 "ext/java/org/liboga/xml/Lexer.rl"

    /* Used by Ragel to keep track of the current state. */
    int act;
    int cs;
    int top;
    int lines;
    int[] stack;

    /**
     * Sets up the current class in the Ruby runtime.
     */
    public static void load(Ruby runtime)
    {
        RubyModule xml = (RubyModule) runtime.getModule("Oga")
            .getConstant("XML");

        RubyClass lexer = xml.defineClassUnder(
            "Lexer",
            runtime.getObject(),
            ALLOCATOR
        );

        lexer.defineAnnotatedMethods(Lexer.class);
    }

    private static final ObjectAllocator ALLOCATOR = new ObjectAllocator()
    {
        public IRubyObject allocate(Ruby runtime, RubyClass klass)
        {
            return new org.liboga.xml.Lexer(runtime, klass);
        }
    };

    public Lexer(Ruby runtime, RubyClass klass)
    {
        super(runtime, klass);

        this.runtime = runtime;
    }

    /**
     * Runs the bulk of the Ragel loop and calls back in to Ruby.
     *
     * This method pulls its data in from the instance variable `@data`. The
     * Ruby side of the Lexer class should set this variable to a String in its
     * constructor method. Encodings are passed along to make sure that token
     * values share the same encoding as the input.
     *
     * This method always returns nil.
     */
    @JRubyMethod
    public IRubyObject advance_native(ThreadContext context, RubyString rb_str)
    {
        Boolean html_p = this.callMethod(context, "html?").isTrue();

        Encoding encoding = rb_str.getEncoding();

        byte[] data = rb_str.getBytes();

        int ts    = 0;
        int te    = 0;
        int p     = 0;
        int mark  = 0;
        int lines = this.lines;
        int pe    = data.length;
        int eof   = data.length;

        String id_advance_line        = "advance_line";
        String id_on_attribute        = "on_attribute";
        String id_on_attribute_ns     = "on_attribute_ns";
        String id_on_cdata_start      = "on_cdata_start";
        String id_on_cdata_body       = "on_cdata_body";
        String id_on_cdata_end        = "on_cdata_end";
        String id_on_comment_start    = "on_comment_start";
        String id_on_comment_body     = "on_comment_body";
        String id_on_comment_end      = "on_comment_end";
        String id_on_doctype_end      = "on_doctype_end";
        String id_on_doctype_inline   = "on_doctype_inline";
        String id_on_doctype_name     = "on_doctype_name";
        String id_on_doctype_start    = "on_doctype_start";
        String id_on_doctype_type     = "on_doctype_type";
        String id_on_element_end      = "on_element_end";
        String id_on_element_name     = "on_element_name";
        String id_on_element_ns       = "on_element_ns";
        String id_on_element_open_end = "on_element_open_end";
        String id_on_proc_ins_end     = "on_proc_ins_end";
        String id_on_proc_ins_name    = "on_proc_ins_name";
        String id_on_proc_ins_start   = "on_proc_ins_start";
        String id_on_proc_ins_body    = "on_proc_ins_body";
        String id_on_string_body      = "on_string_body";
        String id_on_string_dquote    = "on_string_dquote";
        String id_on_string_squote    = "on_string_squote";
        String id_on_text             = "on_text";
        String id_on_xml_decl_end     = "on_xml_decl_end";
        String id_on_xml_decl_start   = "on_xml_decl_start";

        
// line 491 "ext/java/org/liboga/xml/Lexer.java"
	{
	int _klen;
	int _trans = 0;
	int _acts;
	int _nacts;
	int _keys;
	int _goto_targ = 0;

	_goto: while (true) {
	switch ( _goto_targ ) {
	case 0:
	if ( p == pe ) {
		_goto_targ = 4;
		continue _goto;
	}
	if ( ( this.cs) == 0 ) {
		_goto_targ = 5;
		continue _goto;
	}
case 1:
	_acts = _java_lexer_from_state_actions[( this.cs)];
	_nacts = (int) _java_lexer_actions[_acts++];
	while ( _nacts-- > 0 ) {
		switch ( _java_lexer_actions[_acts++] ) {
	case 3:
// line 1 "NONE"
	{ts = p;}
	break;
// line 520 "ext/java/org/liboga/xml/Lexer.java"
		}
	}

	_match: do {
	_keys = _java_lexer_key_offsets[( this.cs)];
	_trans = _java_lexer_index_offsets[( this.cs)];
	_klen = _java_lexer_single_lengths[( this.cs)];
	if ( _klen > 0 ) {
		int _lower = _keys;
		int _mid;
		int _upper = _keys + _klen - 1;
		while (true) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( data[p] < _java_lexer_trans_keys[_mid] )
				_upper = _mid - 1;
			else if ( data[p] > _java_lexer_trans_keys[_mid] )
				_lower = _mid + 1;
			else {
				_trans += (_mid - _keys);
				break _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _java_lexer_range_lengths[( this.cs)];
	if ( _klen > 0 ) {
		int _lower = _keys;
		int _mid;
		int _upper = _keys + (_klen<<1) - 2;
		while (true) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( data[p] < _java_lexer_trans_keys[_mid] )
				_upper = _mid - 2;
			else if ( data[p] > _java_lexer_trans_keys[_mid+1] )
				_lower = _mid + 2;
			else {
				_trans += ((_mid - _keys)>>1);
				break _match;
			}
		}
		_trans += _klen;
	}
	} while (false);

case 3:
	( this.cs) = _java_lexer_trans_targs[_trans];

	if ( _java_lexer_trans_actions[_trans] != 0 ) {
		_acts = _java_lexer_trans_actions[_trans];
		_nacts = (int) _java_lexer_actions[_acts++];
		while ( _nacts-- > 0 )
	{
			switch ( _java_lexer_actions[_acts++] )
			{
	case 0:
// line 61 "ext/ragel/base_lexer.rl"
	{
        if ( data[p] == '\n' ) lines++;
    }
	break;
	case 1:
// line 661 "ext/ragel/base_lexer.rl"
	{ mark = p; }
	break;
	case 4:
// line 1 "NONE"
	{te = p+1;}
	break;
	case 5:
// line 107 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_comment_end);

            ( this.cs) = 35;
        }}
	break;
	case 6:
// line 96 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_comment_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	break;
	case 7:
// line 96 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
            callback(id_on_comment_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	break;
	case 8:
// line 146 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_cdata_end);

            ( this.cs) = 35;
        }}
	break;
	case 9:
// line 135 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_cdata_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	break;
	case 10:
// line 135 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
            callback(id_on_cdata_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	break;
	case 11:
// line 189 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_proc_ins_end);

            ( this.cs) = 35;
        }}
	break;
	case 12:
// line 178 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_proc_ins_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	break;
	case 13:
// line 231 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_string_squote);

            {( this.cs) = ( this.stack)[--( this.top)];_goto_targ = 2; if (true) continue _goto;}
        }}
	break;
	case 14:
// line 205 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_string_body, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	break;
	case 15:
// line 241 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_string_dquote);

            {( this.cs) = ( this.stack)[--( this.top)];_goto_targ = 2; if (true) continue _goto;}
        }}
	break;
	case 16:
// line 205 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_string_body, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	break;
	case 17:
// line 286 "ext/ragel/base_lexer.rl"
	{te = p+1;{ ( this.cs) = 57; }}
	break;
	case 18:
// line 275 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_doctype_inline, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	break;
	case 19:
// line 292 "ext/ragel/base_lexer.rl"
	{( this.act) = 13;}
	break;
	case 20:
// line 303 "ext/ragel/base_lexer.rl"
	{( this.act) = 17;}
	break;
	case 21:
// line 297 "ext/ragel/base_lexer.rl"
	{te = p+1;{ ( this.cs) = 55; }}
	break;
	case 22:
// line 216 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_string_squote);

        {( this.stack)[( this.top)++] = ( this.cs); ( this.cs) = 51; _goto_targ = 2; if (true) continue _goto;}
    }}
	break;
	case 23:
// line 222 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_string_dquote);

        {( this.stack)[( this.top)++] = ( this.cs); ( this.cs) = 53; _goto_targ = 2; if (true) continue _goto;}
    }}
	break;
	case 24:
// line 307 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_doctype_end);
            ( this.cs) = 35;
        }}
	break;
	case 25:
// line 65 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        advance_line(1);
    }}
	break;
	case 26:
// line 314 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	break;
	case 27:
// line 303 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_doctype_name, data, encoding, ts, te);
        }}
	break;
	case 28:
// line 65 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        advance_line(1);
    }}
	break;
	case 29:
// line 1 "NONE"
	{	switch( ( this.act) ) {
	case 13:
	{{p = ((te))-1;}
            callback(id_on_doctype_type, data, encoding, ts, te);
        }
	break;
	case 17:
	{{p = ((te))-1;}
            callback(id_on_doctype_name, data, encoding, ts, te);
        }
	break;
	}
	}
	break;
	case 30:
// line 331 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            callback_simple(id_on_xml_decl_end);

            ( this.cs) = 35;
        }}
	break;
	case 31:
// line 216 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_string_squote);

        {( this.stack)[( this.top)++] = ( this.cs); ( this.cs) = 51; _goto_targ = 2; if (true) continue _goto;}
    }}
	break;
	case 32:
// line 222 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_string_dquote);

        {( this.stack)[( this.top)++] = ( this.cs); ( this.cs) = 53; _goto_targ = 2; if (true) continue _goto;}
    }}
	break;
	case 33:
// line 359 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	break;
	case 34:
// line 345 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            callback(id_on_attribute, data, encoding, ts, te);
        }}
	break;
	case 35:
// line 359 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	break;
	case 36:
// line 396 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            if ( !html_p )
            {
                callback(id_on_element_ns, data, encoding, ts, te - 1);
            }
        }}
	break;
	case 37:
// line 403 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_element_name, data, encoding, ts, te);

            if ( html_p )
            {
                ( this.cs) = 89;
            }
            else
            {
                ( this.cs) = 82;
            }
        }}
	break;
	case 38:
// line 421 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	break;
	case 39:
// line 425 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( this.cs) = 35;
        }}
	break;
	case 40:
// line 436 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	break;
	case 41:
// line 380 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_element_end, data, encoding, ts, te);
    }}
	break;
	case 42:
// line 442 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	break;
	case 43:
// line 444 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            p--;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( this.cs) = 81;
        }}
	break;
	case 44:
// line 457 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            p--;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            if ( html_p )
            {
                ( this.cs) = 79;
            }
            /* XML doesn't support unquoted attribute values */
            else
            {
                {( this.cs) = ( this.stack)[--( this.top)];_goto_targ = 2; if (true) continue _goto;}
            }
        }}
	break;
	case 45:
// line 442 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	break;
	case 46:
// line 69 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        p--;
        {( this.cs) = ( this.stack)[--( this.top)];_goto_targ = 2; if (true) continue _goto;}
    }}
	break;
	case 47:
// line 495 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback_simple(id_on_string_squote);

            callback(id_on_string_body, data, encoding, ts, te);

            callback_simple(id_on_string_squote);
        }}
	break;
	case 48:
// line 511 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_string_squote);

            ( this.cs) = 51;
        }}
	break;
	case 49:
// line 517 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_string_dquote);

            ( this.cs) = 53;
        }}
	break;
	case 50:
// line 69 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        p--;
        {( this.cs) = ( this.stack)[--( this.top)];_goto_targ = 2; if (true) continue _goto;}
    }}
	break;
	case 51:
// line 65 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        advance_line(1);
    }}
	break;
	case 52:
// line 558 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback(id_on_attribute_ns, data, encoding, ts, te - 1);
        }}
	break;
	case 53:
// line 526 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        {( this.stack)[( this.top)++] = ( this.cs); ( this.cs) = 77; _goto_targ = 2; if (true) continue _goto;}
    }}
	break;
	case 54:
// line 568 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_element_open_end);

            ( this.cs) = 35;
        }}
	break;
	case 55:
// line 547 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_element_end);
        ( this.cs) = 35;
    }}
	break;
	case 56:
// line 576 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	break;
	case 57:
// line 65 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        advance_line(1);
    }}
	break;
	case 58:
// line 555 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	break;
	case 59:
// line 562 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_attribute, data, encoding, ts, te);
        }}
	break;
	case 60:
// line 576 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	break;
	case 61:
// line 555 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}}
	break;
	case 62:
// line 65 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        advance_line(1);
    }}
	break;
	case 63:
// line 526 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        {( this.stack)[( this.top)++] = ( this.cs); ( this.cs) = 77; _goto_targ = 2; if (true) continue _goto;}
    }}
	break;
	case 64:
// line 591 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_element_open_end);

            if ( html_script_p() )
            {
                ( this.cs) = 100;
            }
            else if ( html_style_p() )
            {
                ( this.cs) = 104;
            }
            else
            {
                ( this.cs) = 35;
            }
        }}
	break;
	case 65:
// line 547 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_element_end);
        ( this.cs) = 35;
    }}
	break;
	case 66:
// line 610 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	break;
	case 67:
// line 65 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        advance_line(1);
    }}
	break;
	case 68:
// line 583 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	break;
	case 69:
// line 585 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_attribute, data, encoding, ts, te);
        }}
	break;
	case 70:
// line 610 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	break;
	case 71:
// line 583 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}}
	break;
	case 72:
// line 647 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback(id_on_text, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( this.cs) = 35;
        }}
	break;
	case 73:
// line 661 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback(id_on_text, data, encoding, ts, mark);

            p    = mark - 1;
            mark = 0;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( this.cs) = 35;
        }}
	break;
	case 74:
// line 647 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_text, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( this.cs) = 35;
        }}
	break;
	case 75:
// line 384 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_element_end);

        ( this.cs) = 35;
    }}
	break;
	case 76:
// line 635 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	break;
	case 77:
// line 635 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	break;
	case 78:
// line 384 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_element_end);

        ( this.cs) = 35;
    }}
	break;
	case 79:
// line 635 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	break;
	case 80:
// line 635 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	break;
	case 81:
// line 324 "ext/ragel/base_lexer.rl"
	{( this.act) = 62;}
	break;
	case 82:
// line 170 "ext/ragel/base_lexer.rl"
	{( this.act) = 65;}
	break;
	case 83:
// line 89 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_comment_start);

        ( this.cs) = 42;
    }}
	break;
	case 84:
// line 128 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_cdata_start);

        ( this.cs) = 45;
    }}
	break;
	case 85:
// line 371 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        p--;
        ( this.cs) = 73;
    }}
	break;
	case 86:
// line 376 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        ( this.cs) = 75;
    }}
	break;
	case 87:
// line 621 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        p--;
        ( this.cs) = 96;
    }}
	break;
	case 88:
// line 260 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback_simple(id_on_doctype_start);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }

        ( this.cs) = 57;
    }}
	break;
	case 89:
// line 170 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback_simple(id_on_proc_ins_start);
        callback(id_on_proc_ins_name, data, encoding, ts + 2, te);

        ( this.cs) = 48;
    }}
	break;
	case 90:
// line 621 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        p--;
        ( this.cs) = 96;
    }}
	break;
	case 91:
// line 621 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
        p--;
        ( this.cs) = 96;
    }}
	break;
	case 92:
// line 1 "NONE"
	{	switch( ( this.act) ) {
	case 62:
	{{p = ((te))-1;}
        callback_simple(id_on_xml_decl_start);
        ( this.cs) = 70;
    }
	break;
	case 65:
	{{p = ((te))-1;}
        callback_simple(id_on_proc_ins_start);
        callback(id_on_proc_ins_name, data, encoding, ts + 2, te);

        ( this.cs) = 48;
    }
	break;
	}
	}
	break;
// line 1352 "ext/java/org/liboga/xml/Lexer.java"
			}
		}
	}

case 2:
	_acts = _java_lexer_to_state_actions[( this.cs)];
	_nacts = (int) _java_lexer_actions[_acts++];
	while ( _nacts-- > 0 ) {
		switch ( _java_lexer_actions[_acts++] ) {
	case 2:
// line 1 "NONE"
	{ts = -1;}
	break;
// line 1366 "ext/java/org/liboga/xml/Lexer.java"
		}
	}

	if ( ( this.cs) == 0 ) {
		_goto_targ = 5;
		continue _goto;
	}
	if ( ++p != pe ) {
		_goto_targ = 1;
		continue _goto;
	}
case 4:
	if ( p == eof )
	{
	if ( _java_lexer_eof_trans[( this.cs)] > 0 ) {
		_trans = _java_lexer_eof_trans[( this.cs)] - 1;
		_goto_targ = 3;
		continue _goto;
	}
	}

case 5:
	}
	break; }
	}

// line 136 "ext/java/org/liboga/xml/Lexer.rl"

        this.lines = lines;

        return context.nil;
    }

    /**
     * Resets the internal state of the lexer.
     */
    @JRubyMethod
    public IRubyObject reset_native(ThreadContext context)
    {
        this.act   = 0;
        this.top   = 0;
        this.stack = new int[4];
        this.cs    = java_lexer_start;

        return context.nil;
    }

    /**
     * Calls back in to Ruby land passing the current token value along.
     *
     * This method calls back in to Ruby land based on the method name
     * specified in `name`. The Ruby callback should take one argument. This
     * argument will be a String containing the value of the current token.
     */
    public void callback(String name, byte[] data, Encoding enc, int ts, int te)
    {
        ByteList bytelist = new ByteList(data, ts, te - ts, enc, true);

        RubyString value = this.runtime.newString(bytelist);

        ThreadContext context = this.runtime.getCurrentContext();

        this.callMethod(context, name, value);
    }

    /**
     * Calls back in to Ruby land without passing any arguments.
     */
    public void callback_simple(String name)
    {
        ThreadContext context = this.runtime.getCurrentContext();

        this.callMethod(context, name);
    }

    /**
     * Advances the line number by `amount` lines.
     */
    public void advance_line(int amount)
    {
        ThreadContext context = this.runtime.getCurrentContext();
        RubyFixnum lines      = this.runtime.newFixnum(amount);

        this.callMethod(context, "advance_line", lines);
    }

    /**
     * @see Oga::XML::Lexer#html_script?
     */
    public Boolean html_script_p()
    {
        ThreadContext context = this.runtime.getCurrentContext();

        return this.callMethod(context, "html_script?").isTrue();
    }

    /**
     * @see Oga::XML::Lexer#html_style?
     */
    public Boolean html_style_p()
    {
        ThreadContext context = this.runtime.getCurrentContext();

        return this.callMethod(context, "html_style?").isTrue();
    }
}


// line 223 "ext/java/org/liboga/xml/Lexer.rl"

