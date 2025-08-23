
#line 1 "ext/c/lexer.rl"
#include "lexer.h"

/*
The following two macros allow the Ragel grammar to use generic function calls
without relying on the setup of the C or Java lexer. Using these macros we can
also pass along `self` to the callback functions without having to hard-code
this in to the Ragel grammar.

In the C lexer we don't need the `data` variable (since this is pulled in based
on `ts` and `te`) so the macro ignores this argument.
*/

#define callback(name, data, encoding, start, stop) \
    liboga_xml_lexer_callback(self, name, encoding, start, stop);

#define callback_simple(name) \
    liboga_xml_lexer_callback_simple(self, name);

#define advance_line(amount) \
    rb_funcall(self, id_advance_line, 1, INT2NUM(amount));

#define html_script_p() \
    rb_funcall(self, id_html_script_p, 0) == Qtrue

#define html_style_p() \
    rb_funcall(self, id_html_style_p, 0) == Qtrue

ID id_advance_line;
ID id_html_script_p;
ID id_html_style_p;
ID id_html_p;


#line 34 "ext/c/lexer.rl"

/**
 * Calls a method defined in the Ruby side of the lexer. The String value is
 * created based on the values of `ts` and `te` and uses the encoding specified
 * in `encoding`.
 *
 * @example
 *  rb_encoding *encoding = rb_enc_get(...);
 *  liboga_xml_lexer_callback(self, "on_string", encoding, ts, te);
 */
void liboga_xml_lexer_callback(
    VALUE self,
    ID name,
    rb_encoding *encoding,
    const char *ts,
    const char *te
)
{
    VALUE value = rb_enc_str_new(ts, te - ts, encoding);

    rb_funcall(self, name, 1, value);
}

/**
 * Calls a method defined in the Ruby side of the lexer without passing it any
 * arguments.
 *
 * @example
 *  liboga_xml_lexer_callback_simple(self, "on_cdata_start");
 */
void liboga_xml_lexer_callback_simple(VALUE self, VALUE name)
{
    rb_funcall(self, name, 0);
}


#line 74 "ext/c/lexer.c"
static const int c_lexer_start = 35;
static const int c_lexer_first_final = 35;
static const int c_lexer_error = 0;

static const int c_lexer_en_comment_body = 42;
static const int c_lexer_en_cdata_body = 45;
static const int c_lexer_en_proc_ins_body = 48;
static const int c_lexer_en_string_squote = 51;
static const int c_lexer_en_string_dquote = 53;
static const int c_lexer_en_doctype_inline = 55;
static const int c_lexer_en_doctype = 57;
static const int c_lexer_en_xml_decl = 70;
static const int c_lexer_en_element_name = 73;
static const int c_lexer_en_element_close = 75;
static const int c_lexer_en_attribute_pre = 77;
static const int c_lexer_en_unquoted_attribute_value = 79;
static const int c_lexer_en_quoted_attribute_value = 81;
static const int c_lexer_en_element_head = 82;
static const int c_lexer_en_html_element_head = 89;
static const int c_lexer_en_text = 96;
static const int c_lexer_en_html_script = 100;
static const int c_lexer_en_html_style = 104;
static const int c_lexer_en_main = 35;


#line 70 "ext/c/lexer.rl"

/**
 * Lexes the String specifies as the method argument. Token values have the
 * same encoding as the input value.
 *
 * This method keeps track of an internal state using the instance variables
 * `@act` and `@cs`.
 */
VALUE oga_xml_lexer_advance(VALUE self, VALUE data_block)
{
    OgaLexerState *state;
    int lines;

    /* Whether or not HTML mode is enabled */
    int html_p = rb_funcall(self, id_html_p, 0) == Qtrue;

    /* Make sure that all data passed back to Ruby has the proper encoding. */
    rb_encoding *encoding = rb_enc_get(data_block);

    char *data_str_val = StringValueCStr(data_block);

    const char *p    = data_str_val;
    const char *pe   = data_str_val + strlen(data_str_val);
    const char *eof  = pe;
    const char *ts   = 0;
    const char *te   = 0;
    const char *mark = 0;

    ID id_advance_line        = rb_intern("advance_line");
    ID id_on_attribute        = rb_intern("on_attribute");
    ID id_on_attribute_ns     = rb_intern("on_attribute_ns");
    ID id_on_cdata_start      = rb_intern("on_cdata_start");
    ID id_on_cdata_body       = rb_intern("on_cdata_body");
    ID id_on_cdata_end        = rb_intern("on_cdata_end");
    ID id_on_comment_start    = rb_intern("on_comment_start");
    ID id_on_comment_body     = rb_intern("on_comment_body");
    ID id_on_comment_end      = rb_intern("on_comment_end");
    ID id_on_doctype_end      = rb_intern("on_doctype_end");
    ID id_on_doctype_inline   = rb_intern("on_doctype_inline");
    ID id_on_doctype_name     = rb_intern("on_doctype_name");
    ID id_on_doctype_start    = rb_intern("on_doctype_start");
    ID id_on_doctype_type     = rb_intern("on_doctype_type");
    ID id_on_element_end      = rb_intern("on_element_end");
    ID id_on_element_name     = rb_intern("on_element_name");
    ID id_on_element_ns       = rb_intern("on_element_ns");
    ID id_on_element_open_end = rb_intern("on_element_open_end");
    ID id_on_proc_ins_end     = rb_intern("on_proc_ins_end");
    ID id_on_proc_ins_name    = rb_intern("on_proc_ins_name");
    ID id_on_proc_ins_start   = rb_intern("on_proc_ins_start");
    ID id_on_proc_ins_body    = rb_intern("on_proc_ins_body");
    ID id_on_string_body      = rb_intern("on_string_body");
    ID id_on_string_dquote    = rb_intern("on_string_dquote");
    ID id_on_string_squote    = rb_intern("on_string_squote");
    ID id_on_text             = rb_intern("on_text");
    ID id_on_xml_decl_end     = rb_intern("on_xml_decl_end");
    ID id_on_xml_decl_start   = rb_intern("on_xml_decl_start");

    Data_Get_Struct(self, OgaLexerState, state);

    lines = state->lines;

    
#line 163 "ext/c/lexer.c"
	{
	if ( p == pe )
		goto _test_eof;
	goto _resume;

_again:
	switch ( ( state->cs) ) {
		case 35: goto st35;
		case 36: goto st36;
		case 1: goto st1;
		case 2: goto st2;
		case 3: goto st3;
		case 4: goto st4;
		case 5: goto st5;
		case 6: goto st6;
		case 7: goto st7;
		case 8: goto st8;
		case 9: goto st9;
		case 37: goto st37;
		case 10: goto st10;
		case 11: goto st11;
		case 12: goto st12;
		case 13: goto st13;
		case 14: goto st14;
		case 15: goto st15;
		case 16: goto st16;
		case 38: goto st38;
		case 17: goto st17;
		case 39: goto st39;
		case 40: goto st40;
		case 41: goto st41;
		case 42: goto st42;
		case 43: goto st43;
		case 44: goto st44;
		case 18: goto st18;
		case 45: goto st45;
		case 46: goto st46;
		case 47: goto st47;
		case 19: goto st19;
		case 48: goto st48;
		case 49: goto st49;
		case 50: goto st50;
		case 51: goto st51;
		case 52: goto st52;
		case 53: goto st53;
		case 54: goto st54;
		case 55: goto st55;
		case 56: goto st56;
		case 57: goto st57;
		case 58: goto st58;
		case 0: goto st0;
		case 59: goto st59;
		case 60: goto st60;
		case 61: goto st61;
		case 62: goto st62;
		case 63: goto st63;
		case 64: goto st64;
		case 65: goto st65;
		case 66: goto st66;
		case 67: goto st67;
		case 68: goto st68;
		case 69: goto st69;
		case 70: goto st70;
		case 71: goto st71;
		case 72: goto st72;
		case 73: goto st73;
		case 74: goto st74;
		case 75: goto st75;
		case 76: goto st76;
		case 77: goto st77;
		case 78: goto st78;
		case 79: goto st79;
		case 80: goto st80;
		case 81: goto st81;
		case 82: goto st82;
		case 83: goto st83;
		case 84: goto st84;
		case 85: goto st85;
		case 86: goto st86;
		case 87: goto st87;
		case 20: goto st20;
		case 88: goto st88;
		case 89: goto st89;
		case 90: goto st90;
		case 91: goto st91;
		case 92: goto st92;
		case 93: goto st93;
		case 94: goto st94;
		case 21: goto st21;
		case 95: goto st95;
		case 96: goto st96;
		case 97: goto st97;
		case 98: goto st98;
		case 99: goto st99;
		case 100: goto st100;
		case 101: goto st101;
		case 102: goto st102;
		case 22: goto st22;
		case 23: goto st23;
		case 24: goto st24;
		case 25: goto st25;
		case 26: goto st26;
		case 27: goto st27;
		case 28: goto st28;
		case 103: goto st103;
		case 104: goto st104;
		case 105: goto st105;
		case 106: goto st106;
		case 29: goto st29;
		case 30: goto st30;
		case 31: goto st31;
		case 32: goto st32;
		case 33: goto st33;
		case 34: goto st34;
		case 107: goto st107;
	default: break;
	}

	if ( ++p == pe )
		goto _test_eof;
_resume:
	switch ( ( state->cs) )
	{
tr0:
	( state->cs) = 35;
#line 621 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
        p--;
        ( state->cs) = 96;
    }}
	goto _again;
tr4:
	( state->cs) = 35;
#line 89 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_comment_start);

        ( state->cs) = 42;
    }}
	goto _again;
tr17:
	( state->cs) = 35;
#line 128 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_cdata_start);

        ( state->cs) = 45;
    }}
	goto _again;
tr20:
	( state->cs) = 35;
#line 1 "NONE"
	{	switch( ( state->act) ) {
	case 62:
	{{p = ((te))-1;}
        callback_simple(id_on_xml_decl_start);
        ( state->cs) = 70;
    }
	break;
	case 65:
	{{p = ((te))-1;}
        callback_simple(id_on_proc_ins_start);
        callback(id_on_proc_ins_name, data, encoding, ts + 2, te);

        ( state->cs) = 48;
    }
	break;
	}
	}
	goto _again;
tr45:
	( state->cs) = 35;
#line 621 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        p--;
        ( state->cs) = 96;
    }}
	goto _again;
tr47:
	( state->cs) = 35;
#line 621 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        p--;
        ( state->cs) = 96;
    }}
	goto _again;
tr48:
	( state->cs) = 35;
#line 371 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        p--;
        ( state->cs) = 73;
    }}
	goto _again;
tr50:
	( state->cs) = 35;
#line 376 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        ( state->cs) = 75;
    }}
	goto _again;
tr52:
	( state->cs) = 35;
#line 260 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback_simple(id_on_doctype_start);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }

        ( state->cs) = 57;
    }}
	goto _again;
tr54:
	( state->cs) = 35;
#line 170 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback_simple(id_on_proc_ins_start);
        callback(id_on_proc_ins_name, data, encoding, ts + 2, te);

        ( state->cs) = 48;
    }}
	goto _again;
st35:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof35;
case 35:
#line 1 "NONE"
	{ts = p;}
#line 399 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr46;
	goto tr45;
tr46:
#line 1 "NONE"
	{te = p+1;}
	goto st36;
st36:
	if ( ++p == pe )
		goto _test_eof36;
case 36:
#line 411 "ext/c/lexer.c"
	switch( (*p) ) {
		case 33: goto st1;
		case 47: goto tr50;
		case 63: goto st16;
		case 96: goto tr47;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr47;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr47;
		} else if ( (*p) >= 91 )
			goto tr47;
	} else
		goto tr47;
	goto tr48;
st1:
	if ( ++p == pe )
		goto _test_eof1;
case 1:
	switch( (*p) ) {
		case 45: goto st2;
		case 68: goto st3;
		case 91: goto st10;
		case 100: goto st3;
	}
	goto tr0;
st2:
	if ( ++p == pe )
		goto _test_eof2;
case 2:
	if ( (*p) == 45 )
		goto tr4;
	goto tr0;
st3:
	if ( ++p == pe )
		goto _test_eof3;
case 3:
	switch( (*p) ) {
		case 79: goto st4;
		case 111: goto st4;
	}
	goto tr0;
st4:
	if ( ++p == pe )
		goto _test_eof4;
case 4:
	switch( (*p) ) {
		case 67: goto st5;
		case 99: goto st5;
	}
	goto tr0;
st5:
	if ( ++p == pe )
		goto _test_eof5;
case 5:
	switch( (*p) ) {
		case 84: goto st6;
		case 116: goto st6;
	}
	goto tr0;
st6:
	if ( ++p == pe )
		goto _test_eof6;
case 6:
	switch( (*p) ) {
		case 89: goto st7;
		case 121: goto st7;
	}
	goto tr0;
st7:
	if ( ++p == pe )
		goto _test_eof7;
case 7:
	switch( (*p) ) {
		case 80: goto st8;
		case 112: goto st8;
	}
	goto tr0;
st8:
	if ( ++p == pe )
		goto _test_eof8;
case 8:
	switch( (*p) ) {
		case 69: goto st9;
		case 101: goto st9;
	}
	goto tr0;
st9:
	if ( ++p == pe )
		goto _test_eof9;
case 9:
	switch( (*p) ) {
		case 13: goto tr11;
		case 32: goto tr11;
	}
	if ( 9 <= (*p) && (*p) <= 10 )
		goto tr11;
	goto tr0;
tr11:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st37;
st37:
	if ( ++p == pe )
		goto _test_eof37;
case 37:
#line 523 "ext/c/lexer.c"
	switch( (*p) ) {
		case 13: goto tr11;
		case 32: goto tr11;
	}
	if ( 9 <= (*p) && (*p) <= 10 )
		goto tr11;
	goto tr52;
st10:
	if ( ++p == pe )
		goto _test_eof10;
case 10:
	if ( (*p) == 67 )
		goto st11;
	goto tr0;
st11:
	if ( ++p == pe )
		goto _test_eof11;
case 11:
	if ( (*p) == 68 )
		goto st12;
	goto tr0;
st12:
	if ( ++p == pe )
		goto _test_eof12;
case 12:
	if ( (*p) == 65 )
		goto st13;
	goto tr0;
st13:
	if ( ++p == pe )
		goto _test_eof13;
case 13:
	if ( (*p) == 84 )
		goto st14;
	goto tr0;
st14:
	if ( ++p == pe )
		goto _test_eof14;
case 14:
	if ( (*p) == 65 )
		goto st15;
	goto tr0;
st15:
	if ( ++p == pe )
		goto _test_eof15;
case 15:
	if ( (*p) == 91 )
		goto tr17;
	goto tr0;
st16:
	if ( ++p == pe )
		goto _test_eof16;
case 16:
	switch( (*p) ) {
		case 47: goto tr0;
		case 96: goto tr0;
		case 120: goto tr19;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr0;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr0;
		} else if ( (*p) >= 91 )
			goto tr0;
	} else
		goto tr0;
	goto tr18;
tr18:
#line 1 "NONE"
	{te = p+1;}
#line 170 "ext/ragel/base_lexer.rl"
	{( state->act) = 65;}
	goto st38;
tr56:
#line 1 "NONE"
	{te = p+1;}
#line 324 "ext/ragel/base_lexer.rl"
	{( state->act) = 62;}
	goto st38;
st38:
	if ( ++p == pe )
		goto _test_eof38;
case 38:
#line 610 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr20;
		case 58: goto st17;
		case 96: goto tr20;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr20;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr20;
		} else if ( (*p) >= 91 )
			goto tr20;
	} else
		goto tr20;
	goto tr18;
st17:
	if ( ++p == pe )
		goto _test_eof17;
case 17:
	switch( (*p) ) {
		case 47: goto tr20;
		case 96: goto tr20;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr20;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr20;
		} else if ( (*p) >= 91 )
			goto tr20;
	} else
		goto tr20;
	goto st39;
st39:
	if ( ++p == pe )
		goto _test_eof39;
case 39:
	switch( (*p) ) {
		case 47: goto tr54;
		case 96: goto tr54;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr54;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr54;
		} else if ( (*p) >= 91 )
			goto tr54;
	} else
		goto tr54;
	goto st39;
tr19:
#line 1 "NONE"
	{te = p+1;}
#line 170 "ext/ragel/base_lexer.rl"
	{( state->act) = 65;}
	goto st40;
st40:
	if ( ++p == pe )
		goto _test_eof40;
case 40:
#line 678 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr54;
		case 58: goto st17;
		case 96: goto tr54;
		case 109: goto tr55;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr54;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr54;
		} else if ( (*p) >= 91 )
			goto tr54;
	} else
		goto tr54;
	goto tr18;
tr55:
#line 1 "NONE"
	{te = p+1;}
#line 170 "ext/ragel/base_lexer.rl"
	{( state->act) = 65;}
	goto st41;
st41:
	if ( ++p == pe )
		goto _test_eof41;
case 41:
#line 707 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr54;
		case 58: goto st17;
		case 96: goto tr54;
		case 108: goto tr56;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr54;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr54;
		} else if ( (*p) >= 91 )
			goto tr54;
	} else
		goto tr54;
	goto tr18;
tr22:
#line 96 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
            callback(id_on_comment_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	goto st42;
tr23:
	( state->cs) = 42;
#line 107 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_comment_end);

            ( state->cs) = 35;
        }}
	goto _again;
tr59:
#line 96 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_comment_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	goto st42;
st42:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof42;
case 42:
#line 1 "NONE"
	{ts = p;}
#line 769 "ext/c/lexer.c"
	if ( (*p) == 45 )
		goto tr58;
	goto tr57;
tr57:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st43;
st43:
	if ( ++p == pe )
		goto _test_eof43;
case 43:
#line 783 "ext/c/lexer.c"
	if ( (*p) == 45 )
		goto tr59;
	goto tr57;
tr58:
#line 1 "NONE"
	{te = p+1;}
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st44;
st44:
	if ( ++p == pe )
		goto _test_eof44;
case 44:
#line 799 "ext/c/lexer.c"
	if ( (*p) == 45 )
		goto st18;
	goto tr59;
st18:
	if ( ++p == pe )
		goto _test_eof18;
case 18:
	if ( (*p) == 62 )
		goto tr23;
	goto tr22;
tr24:
#line 135 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
            callback(id_on_cdata_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	goto st45;
tr25:
	( state->cs) = 45;
#line 146 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_cdata_end);

            ( state->cs) = 35;
        }}
	goto _again;
tr63:
#line 135 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_cdata_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	goto st45;
st45:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof45;
case 45:
#line 1 "NONE"
	{ts = p;}
#line 853 "ext/c/lexer.c"
	if ( (*p) == 93 )
		goto tr62;
	goto tr61;
tr61:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st46;
st46:
	if ( ++p == pe )
		goto _test_eof46;
case 46:
#line 867 "ext/c/lexer.c"
	if ( (*p) == 93 )
		goto tr63;
	goto tr61;
tr62:
#line 1 "NONE"
	{te = p+1;}
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st47;
st47:
	if ( ++p == pe )
		goto _test_eof47;
case 47:
#line 883 "ext/c/lexer.c"
	if ( (*p) == 93 )
		goto st19;
	goto tr63;
st19:
	if ( ++p == pe )
		goto _test_eof19;
case 19:
	if ( (*p) == 62 )
		goto tr25;
	goto tr24;
tr67:
#line 178 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_proc_ins_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	goto st48;
tr68:
	( state->cs) = 48;
#line 189 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_proc_ins_end);

            ( state->cs) = 35;
        }}
	goto _again;
st48:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof48;
case 48:
#line 1 "NONE"
	{ts = p;}
#line 924 "ext/c/lexer.c"
	if ( (*p) == 63 )
		goto tr66;
	goto tr65;
tr65:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st49;
st49:
	if ( ++p == pe )
		goto _test_eof49;
case 49:
#line 938 "ext/c/lexer.c"
	if ( (*p) == 63 )
		goto tr67;
	goto tr65;
tr66:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st50;
st50:
	if ( ++p == pe )
		goto _test_eof50;
case 50:
#line 952 "ext/c/lexer.c"
	if ( (*p) == 62 )
		goto tr68;
	goto tr67;
tr70:
#line 231 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_string_squote);

            {( state->cs) = ( state->stack)[--( state->top)];goto _again;}
        }}
	goto st51;
tr71:
#line 205 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_string_body, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	goto st51;
st51:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof51;
case 51:
#line 1 "NONE"
	{ts = p;}
#line 985 "ext/c/lexer.c"
	if ( (*p) == 39 )
		goto tr70;
	goto tr69;
tr69:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st52;
st52:
	if ( ++p == pe )
		goto _test_eof52;
case 52:
#line 999 "ext/c/lexer.c"
	if ( (*p) == 39 )
		goto tr71;
	goto tr69;
tr73:
#line 241 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_string_dquote);

            {( state->cs) = ( state->stack)[--( state->top)];goto _again;}
        }}
	goto st53;
tr74:
#line 205 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_string_body, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	goto st53;
st53:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof53;
case 53:
#line 1 "NONE"
	{ts = p;}
#line 1032 "ext/c/lexer.c"
	if ( (*p) == 34 )
		goto tr73;
	goto tr72;
tr72:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st54;
st54:
	if ( ++p == pe )
		goto _test_eof54;
case 54:
#line 1046 "ext/c/lexer.c"
	if ( (*p) == 34 )
		goto tr74;
	goto tr72;
tr76:
	( state->cs) = 55;
#line 286 "ext/ragel/base_lexer.rl"
	{te = p+1;{ ( state->cs) = 57; }}
	goto _again;
tr77:
#line 275 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_doctype_inline, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        }}
	goto st55;
st55:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof55;
case 55:
#line 1 "NONE"
	{ts = p;}
#line 1076 "ext/c/lexer.c"
	if ( (*p) == 93 )
		goto tr76;
	goto tr75;
tr75:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st56;
st56:
	if ( ++p == pe )
		goto _test_eof56;
case 56:
#line 1090 "ext/c/lexer.c"
	if ( (*p) == 93 )
		goto tr77;
	goto tr75;
tr79:
#line 314 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	goto st57;
tr81:
#line 65 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        advance_line(1);
    }}
	goto st57;
tr83:
#line 222 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_string_dquote);

        {( state->stack)[( state->top)++] = 57;goto st53;}
    }}
	goto st57;
tr84:
#line 216 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_string_squote);

        {( state->stack)[( state->top)++] = 57;goto st51;}
    }}
	goto st57;
tr85:
	( state->cs) = 57;
#line 307 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_doctype_end);
            ( state->cs) = 35;
        }}
	goto _again;
tr88:
	( state->cs) = 57;
#line 297 "ext/ragel/base_lexer.rl"
	{te = p+1;{ ( state->cs) = 55; }}
	goto _again;
tr89:
#line 1 "NONE"
	{	switch( ( state->act) ) {
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
	goto st57;
tr90:
#line 65 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        advance_line(1);
    }}
	goto st57;
tr91:
#line 303 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_doctype_name, data, encoding, ts, te);
        }}
	goto st57;
st57:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof57;
case 57:
#line 1 "NONE"
	{ts = p;}
#line 1169 "ext/c/lexer.c"
	switch( (*p) ) {
		case 9: goto tr79;
		case 10: goto tr81;
		case 13: goto st59;
		case 32: goto tr79;
		case 34: goto tr83;
		case 39: goto tr84;
		case 47: goto st0;
		case 62: goto tr85;
		case 80: goto st60;
		case 83: goto st65;
		case 91: goto tr88;
		case 96: goto st0;
		case 112: goto st60;
		case 115: goto st65;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto st0;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto st0;
		} else if ( (*p) >= 92 )
			goto st0;
	} else
		goto st0;
	goto tr78;
tr78:
#line 1 "NONE"
	{te = p+1;}
#line 303 "ext/ragel/base_lexer.rl"
	{( state->act) = 17;}
	goto st58;
tr96:
#line 1 "NONE"
	{te = p+1;}
#line 292 "ext/ragel/base_lexer.rl"
	{( state->act) = 13;}
	goto st58;
st58:
	if ( ++p == pe )
		goto _test_eof58;
case 58:
#line 1214 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr89;
		case 96: goto tr89;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr89;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr89;
		} else if ( (*p) >= 91 )
			goto tr89;
	} else
		goto tr89;
	goto tr78;
st0:
( state->cs) = 0;
	goto _out;
st59:
	if ( ++p == pe )
		goto _test_eof59;
case 59:
	if ( (*p) == 10 )
		goto tr81;
	goto tr90;
st60:
	if ( ++p == pe )
		goto _test_eof60;
case 60:
	switch( (*p) ) {
		case 47: goto tr91;
		case 85: goto st61;
		case 96: goto tr91;
		case 117: goto st61;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st61:
	if ( ++p == pe )
		goto _test_eof61;
case 61:
	switch( (*p) ) {
		case 47: goto tr91;
		case 66: goto st62;
		case 96: goto tr91;
		case 98: goto st62;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st62:
	if ( ++p == pe )
		goto _test_eof62;
case 62:
	switch( (*p) ) {
		case 47: goto tr91;
		case 76: goto st63;
		case 96: goto tr91;
		case 108: goto st63;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st63:
	if ( ++p == pe )
		goto _test_eof63;
case 63:
	switch( (*p) ) {
		case 47: goto tr91;
		case 73: goto st64;
		case 96: goto tr91;
		case 105: goto st64;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st64:
	if ( ++p == pe )
		goto _test_eof64;
case 64:
	switch( (*p) ) {
		case 47: goto tr91;
		case 67: goto tr96;
		case 96: goto tr91;
		case 99: goto tr96;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st65:
	if ( ++p == pe )
		goto _test_eof65;
case 65:
	switch( (*p) ) {
		case 47: goto tr91;
		case 89: goto st66;
		case 96: goto tr91;
		case 121: goto st66;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st66:
	if ( ++p == pe )
		goto _test_eof66;
case 66:
	switch( (*p) ) {
		case 47: goto tr91;
		case 83: goto st67;
		case 96: goto tr91;
		case 115: goto st67;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st67:
	if ( ++p == pe )
		goto _test_eof67;
case 67:
	switch( (*p) ) {
		case 47: goto tr91;
		case 84: goto st68;
		case 96: goto tr91;
		case 116: goto st68;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st68:
	if ( ++p == pe )
		goto _test_eof68;
case 68:
	switch( (*p) ) {
		case 47: goto tr91;
		case 69: goto st69;
		case 96: goto tr91;
		case 101: goto st69;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
st69:
	if ( ++p == pe )
		goto _test_eof69;
case 69:
	switch( (*p) ) {
		case 47: goto tr91;
		case 77: goto tr96;
		case 96: goto tr91;
		case 109: goto tr96;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr91;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr91;
		} else if ( (*p) >= 91 )
			goto tr91;
	} else
		goto tr91;
	goto tr78;
tr102:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
#line 359 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	goto st70;
tr103:
#line 222 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_string_dquote);

        {( state->stack)[( state->top)++] = 70;goto st53;}
    }}
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st70;
tr104:
#line 216 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_string_squote);

        {( state->stack)[( state->top)++] = 70;goto st51;}
    }}
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st70;
tr106:
#line 345 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            callback(id_on_attribute, data, encoding, ts, te);
        }}
	goto st70;
tr108:
#line 359 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	goto st70;
tr109:
	( state->cs) = 70;
#line 331 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            callback_simple(id_on_xml_decl_end);

            ( state->cs) = 35;
        }}
	goto _again;
st70:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof70;
case 70:
#line 1 "NONE"
	{ts = p;}
#line 1534 "ext/c/lexer.c"
	switch( (*p) ) {
		case 34: goto tr103;
		case 39: goto tr104;
		case 47: goto tr102;
		case 63: goto tr105;
		case 96: goto tr102;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr102;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr102;
		} else if ( (*p) >= 91 )
			goto tr102;
	} else
		goto tr102;
	goto tr101;
tr101:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st71;
st71:
	if ( ++p == pe )
		goto _test_eof71;
case 71:
#line 1564 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr106;
		case 96: goto tr106;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr106;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr106;
		} else if ( (*p) >= 91 )
			goto tr106;
	} else
		goto tr106;
	goto st71;
tr105:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st72;
st72:
	if ( ++p == pe )
		goto _test_eof72;
case 72:
#line 1591 "ext/c/lexer.c"
	if ( (*p) == 62 )
		goto tr109;
	goto tr108;
tr111:
	( state->cs) = 73;
#line 403 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_element_name, data, encoding, ts, te);

            if ( html_p )
            {
                ( state->cs) = 89;
            }
            else
            {
                ( state->cs) = 82;
            }
        }}
	goto _again;
tr112:
#line 396 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            if ( !html_p )
            {
                callback(id_on_element_ns, data, encoding, ts, te - 1);
            }
        }}
	goto st73;
st73:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof73;
case 73:
#line 1 "NONE"
	{ts = p;}
#line 1628 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto st0;
		case 96: goto st0;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto st0;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto st0;
		} else if ( (*p) >= 91 )
			goto st0;
	} else
		goto st0;
	goto st74;
st74:
	if ( ++p == pe )
		goto _test_eof74;
case 74:
	switch( (*p) ) {
		case 47: goto tr111;
		case 58: goto tr112;
		case 96: goto tr111;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr111;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr111;
		} else if ( (*p) >= 91 )
			goto tr111;
	} else
		goto tr111;
	goto st74;
tr114:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
#line 436 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	goto st75;
tr115:
	( state->cs) = 75;
#line 425 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( state->cs) = 35;
        }}
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto _again;
tr116:
#line 380 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_element_end, data, encoding, ts, te);
    }}
	goto st75;
tr118:
#line 421 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	goto st75;
st75:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof75;
case 75:
#line 1 "NONE"
	{ts = p;}
#line 1710 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr114;
		case 62: goto tr115;
		case 96: goto tr114;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr114;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr114;
		} else if ( (*p) >= 91 )
			goto tr114;
	} else
		goto tr114;
	goto tr113;
tr113:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st76;
st76:
	if ( ++p == pe )
		goto _test_eof76;
case 76:
#line 1738 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr116;
		case 58: goto tr118;
		case 96: goto tr116;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr116;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr116;
		} else if ( (*p) >= 91 )
			goto tr116;
	} else
		goto tr116;
	goto st76;
tr119:
	( state->cs) = 77;
#line 457 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            p--;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            if ( html_p )
            {
                ( state->cs) = 79;
            }
            /* XML doesn't support unquoted attribute values */
            else
            {
                {( state->cs) = ( state->stack)[--( state->top)];goto _again;}
            }
        }}
	goto _again;
tr120:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
#line 442 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	goto st77;
tr122:
	( state->cs) = 77;
#line 444 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            p--;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( state->cs) = 81;
        }}
	goto _again;
tr123:
#line 442 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	goto st77;
st77:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof77;
case 77:
#line 1 "NONE"
	{ts = p;}
#line 1816 "ext/c/lexer.c"
	switch( (*p) ) {
		case 13: goto tr121;
		case 32: goto tr120;
		case 34: goto tr122;
		case 39: goto tr122;
	}
	if ( 9 <= (*p) && (*p) <= 10 )
		goto tr120;
	goto tr119;
tr121:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st78;
st78:
	if ( ++p == pe )
		goto _test_eof78;
case 78:
#line 1836 "ext/c/lexer.c"
	if ( (*p) == 10 )
		goto tr120;
	goto tr123;
tr125:
#line 69 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        p--;
        {( state->cs) = ( state->stack)[--( state->top)];goto _again;}
    }}
	goto st79;
tr126:
#line 495 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback_simple(id_on_string_squote);

            callback(id_on_string_body, data, encoding, ts, te);

            callback_simple(id_on_string_squote);
        }}
	goto st79;
st79:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof79;
case 79:
#line 1 "NONE"
	{ts = p;}
#line 1865 "ext/c/lexer.c"
	switch( (*p) ) {
		case 13: goto tr125;
		case 32: goto tr125;
		case 62: goto tr125;
	}
	if ( 9 <= (*p) && (*p) <= 10 )
		goto tr125;
	goto st80;
st80:
	if ( ++p == pe )
		goto _test_eof80;
case 80:
	switch( (*p) ) {
		case 13: goto tr126;
		case 32: goto tr126;
		case 62: goto tr126;
	}
	if ( 9 <= (*p) && (*p) <= 10 )
		goto tr126;
	goto st80;
tr127:
#line 69 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        p--;
        {( state->cs) = ( state->stack)[--( state->top)];goto _again;}
    }}
	goto st81;
tr128:
	( state->cs) = 81;
#line 517 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_string_dquote);

            ( state->cs) = 53;
        }}
	goto _again;
tr129:
	( state->cs) = 81;
#line 511 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_string_squote);

            ( state->cs) = 51;
        }}
	goto _again;
st81:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof81;
case 81:
#line 1 "NONE"
	{ts = p;}
#line 1919 "ext/c/lexer.c"
	switch( (*p) ) {
		case 34: goto tr128;
		case 39: goto tr129;
	}
	goto tr127;
tr26:
#line 555 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}}
	goto st82;
tr131:
#line 576 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	goto st82;
tr132:
#line 65 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        advance_line(1);
    }}
	goto st82;
tr136:
#line 526 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        {( state->stack)[( state->top)++] = 82;goto st77;}
    }}
	goto st82;
tr137:
	( state->cs) = 82;
#line 568 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_element_open_end);

            ( state->cs) = 35;
        }}
	goto _again;
tr138:
#line 562 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_attribute, data, encoding, ts, te);
        }}
	goto st82;
tr139:
#line 558 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback(id_on_attribute_ns, data, encoding, ts, te - 1);
        }}
	goto st82;
tr140:
#line 65 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        advance_line(1);
    }}
	goto st82;
tr141:
#line 576 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	goto st82;
tr142:
	( state->cs) = 82;
#line 547 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_element_end);
        ( state->cs) = 35;
    }}
	goto _again;
tr144:
#line 555 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	goto st82;
st82:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof82;
case 82:
#line 1 "NONE"
	{ts = p;}
#line 1996 "ext/c/lexer.c"
	switch( (*p) ) {
		case 10: goto tr132;
		case 13: goto st84;
		case 47: goto st85;
		case 60: goto st86;
		case 61: goto tr136;
		case 62: goto tr137;
		case 96: goto tr131;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr131;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr131;
		} else if ( (*p) >= 91 )
			goto tr131;
	} else
		goto tr131;
	goto st83;
st83:
	if ( ++p == pe )
		goto _test_eof83;
case 83:
	switch( (*p) ) {
		case 47: goto tr138;
		case 58: goto tr139;
		case 96: goto tr138;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr138;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr138;
		} else if ( (*p) >= 91 )
			goto tr138;
	} else
		goto tr138;
	goto st83;
st84:
	if ( ++p == pe )
		goto _test_eof84;
case 84:
	if ( (*p) == 10 )
		goto tr132;
	goto tr140;
st85:
	if ( ++p == pe )
		goto _test_eof85;
case 85:
	if ( (*p) == 62 )
		goto tr142;
	goto tr141;
st86:
	if ( ++p == pe )
		goto _test_eof86;
case 86:
	switch( (*p) ) {
		case 47: goto tr141;
		case 96: goto tr141;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr141;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr141;
		} else if ( (*p) >= 91 )
			goto tr141;
	} else
		goto tr141;
	goto tr143;
tr143:
#line 1 "NONE"
	{te = p+1;}
	goto st87;
st87:
	if ( ++p == pe )
		goto _test_eof87;
case 87:
#line 2081 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr144;
		case 58: goto st20;
		case 96: goto tr144;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr144;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr144;
		} else if ( (*p) >= 91 )
			goto tr144;
	} else
		goto tr144;
	goto tr143;
st20:
	if ( ++p == pe )
		goto _test_eof20;
case 20:
	switch( (*p) ) {
		case 47: goto tr26;
		case 96: goto tr26;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr26;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr26;
		} else if ( (*p) >= 91 )
			goto tr26;
	} else
		goto tr26;
	goto st88;
st88:
	if ( ++p == pe )
		goto _test_eof88;
case 88:
	switch( (*p) ) {
		case 47: goto tr144;
		case 96: goto tr144;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr144;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr144;
		} else if ( (*p) >= 91 )
			goto tr144;
	} else
		goto tr144;
	goto st88;
tr28:
#line 583 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}}
	goto st89;
tr147:
#line 610 "ext/ragel/base_lexer.rl"
	{te = p+1;}
	goto st89;
tr148:
#line 65 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        advance_line(1);
    }}
	goto st89;
tr152:
#line 526 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        {( state->stack)[( state->top)++] = 89;goto st77;}
    }}
	goto st89;
tr153:
	( state->cs) = 89;
#line 591 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback_simple(id_on_element_open_end);

            if ( html_script_p() )
            {
                ( state->cs) = 100;
            }
            else if ( html_style_p() )
            {
                ( state->cs) = 104;
            }
            else
            {
                ( state->cs) = 35;
            }
        }}
	goto _again;
tr154:
#line 585 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_attribute, data, encoding, ts, te);
        }}
	goto st89;
tr155:
#line 65 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        advance_line(1);
    }}
	goto st89;
tr156:
#line 610 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	goto st89;
tr157:
	( state->cs) = 89;
#line 547 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_element_end);
        ( state->cs) = 35;
    }}
	goto _again;
tr159:
#line 583 "ext/ragel/base_lexer.rl"
	{te = p;p--;}
	goto st89;
st89:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof89;
case 89:
#line 1 "NONE"
	{ts = p;}
#line 2215 "ext/c/lexer.c"
	switch( (*p) ) {
		case 10: goto tr148;
		case 13: goto st91;
		case 47: goto st92;
		case 60: goto st93;
		case 61: goto tr152;
		case 62: goto tr153;
		case 96: goto tr147;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr147;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr147;
		} else if ( (*p) >= 91 )
			goto tr147;
	} else
		goto tr147;
	goto st90;
st90:
	if ( ++p == pe )
		goto _test_eof90;
case 90:
	switch( (*p) ) {
		case 47: goto tr154;
		case 96: goto tr154;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr154;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr154;
		} else if ( (*p) >= 91 )
			goto tr154;
	} else
		goto tr154;
	goto st90;
st91:
	if ( ++p == pe )
		goto _test_eof91;
case 91:
	if ( (*p) == 10 )
		goto tr148;
	goto tr155;
st92:
	if ( ++p == pe )
		goto _test_eof92;
case 92:
	if ( (*p) == 62 )
		goto tr157;
	goto tr156;
st93:
	if ( ++p == pe )
		goto _test_eof93;
case 93:
	switch( (*p) ) {
		case 47: goto tr156;
		case 96: goto tr156;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr156;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr156;
		} else if ( (*p) >= 91 )
			goto tr156;
	} else
		goto tr156;
	goto tr158;
tr158:
#line 1 "NONE"
	{te = p+1;}
	goto st94;
st94:
	if ( ++p == pe )
		goto _test_eof94;
case 94:
#line 2299 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto tr159;
		case 58: goto st21;
		case 96: goto tr159;
	}
	if ( (*p) < 59 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr159;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr159;
		} else if ( (*p) >= 91 )
			goto tr159;
	} else
		goto tr159;
	goto tr158;
st21:
	if ( ++p == pe )
		goto _test_eof21;
case 21:
	switch( (*p) ) {
		case 47: goto tr28;
		case 96: goto tr28;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr28;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr28;
		} else if ( (*p) >= 91 )
			goto tr28;
	} else
		goto tr28;
	goto st95;
st95:
	if ( ++p == pe )
		goto _test_eof95;
case 95:
	switch( (*p) ) {
		case 47: goto tr159;
		case 96: goto tr159;
	}
	if ( (*p) < 58 ) {
		if ( 0 <= (*p) && (*p) <= 44 )
			goto tr159;
	} else if ( (*p) > 64 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr159;
		} else if ( (*p) >= 91 )
			goto tr159;
	} else
		goto tr159;
	goto st95;
tr163:
	( state->cs) = 96;
#line 647 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
            callback(id_on_text, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( state->cs) = 35;
        }}
	goto _again;
tr165:
	( state->cs) = 96;
#line 661 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback(id_on_text, data, encoding, ts, mark);

            p    = mark - 1;
            mark = 0;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( state->cs) = 35;
        }}
	goto _again;
tr166:
	( state->cs) = 96;
#line 647 "ext/ragel/base_lexer.rl"
	{te = p+1;{
            callback(id_on_text, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            ( state->cs) = 35;
        }}
	goto _again;
st96:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof96;
case 96:
#line 1 "NONE"
	{ts = p;}
#line 2416 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr162;
	goto tr161;
tr161:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st97;
st97:
	if ( ++p == pe )
		goto _test_eof97;
case 97:
#line 2430 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr164;
	goto tr161;
tr164:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
#line 661 "ext/ragel/base_lexer.rl"
	{ mark = p; }
	goto st98;
st98:
	if ( ++p == pe )
		goto _test_eof98;
case 98:
#line 2446 "ext/c/lexer.c"
	switch( (*p) ) {
		case 60: goto tr164;
		case 64: goto tr161;
		case 96: goto tr161;
	}
	if ( (*p) < 58 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 44 )
				goto tr161;
		} else if ( (*p) >= 0 )
			goto tr161;
	} else if ( (*p) > 62 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr161;
		} else if ( (*p) >= 91 )
			goto tr161;
	} else
		goto tr161;
	goto tr165;
tr162:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
#line 661 "ext/ragel/base_lexer.rl"
	{ mark = p; }
	goto st99;
st99:
	if ( ++p == pe )
		goto _test_eof99;
case 99:
#line 2479 "ext/c/lexer.c"
	switch( (*p) ) {
		case 60: goto tr164;
		case 64: goto tr161;
		case 96: goto tr161;
	}
	if ( (*p) < 58 ) {
		if ( (*p) > 32 ) {
			if ( 34 <= (*p) && (*p) <= 44 )
				goto tr161;
		} else if ( (*p) >= 0 )
			goto tr161;
	} else if ( (*p) > 62 ) {
		if ( (*p) > 94 ) {
			if ( 123 <= (*p) )
				goto tr161;
		} else if ( (*p) >= 91 )
			goto tr161;
	} else
		goto tr161;
	goto tr166;
tr30:
#line 635 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	goto st100;
tr37:
	( state->cs) = 100;
#line 384 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_element_end);

        ( state->cs) = 35;
    }}
	goto _again;
tr169:
#line 635 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	goto st100;
st100:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof100;
case 100:
#line 1 "NONE"
	{ts = p;}
#line 2543 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr168;
	goto tr167;
tr167:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st101;
st101:
	if ( ++p == pe )
		goto _test_eof101;
case 101:
#line 2557 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr169;
	goto tr167;
tr168:
#line 1 "NONE"
	{te = p+1;}
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st102;
st102:
	if ( ++p == pe )
		goto _test_eof102;
case 102:
#line 2573 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto st22;
		case 60: goto tr171;
	}
	goto tr169;
st22:
	if ( ++p == pe )
		goto _test_eof22;
case 22:
	if ( (*p) == 115 )
		goto st23;
	goto tr30;
st23:
	if ( ++p == pe )
		goto _test_eof23;
case 23:
	if ( (*p) == 99 )
		goto st24;
	goto tr30;
st24:
	if ( ++p == pe )
		goto _test_eof24;
case 24:
	if ( (*p) == 114 )
		goto st25;
	goto tr30;
st25:
	if ( ++p == pe )
		goto _test_eof25;
case 25:
	if ( (*p) == 105 )
		goto st26;
	goto tr30;
st26:
	if ( ++p == pe )
		goto _test_eof26;
case 26:
	if ( (*p) == 112 )
		goto st27;
	goto tr30;
st27:
	if ( ++p == pe )
		goto _test_eof27;
case 27:
	if ( (*p) == 116 )
		goto st28;
	goto tr30;
st28:
	if ( ++p == pe )
		goto _test_eof28;
case 28:
	if ( (*p) == 62 )
		goto tr37;
	goto tr30;
tr171:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st103;
st103:
	if ( ++p == pe )
		goto _test_eof103;
case 103:
#line 2638 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr171;
	goto tr169;
tr38:
#line 635 "ext/ragel/base_lexer.rl"
	{{p = ((te))-1;}{
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	goto st104;
tr44:
	( state->cs) = 104;
#line 384 "ext/ragel/base_lexer.rl"
	{te = p+1;{
        callback_simple(id_on_element_end);

        ( state->cs) = 35;
    }}
	goto _again;
tr174:
#line 635 "ext/ragel/base_lexer.rl"
	{te = p;p--;{
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }}
	goto st104;
st104:
#line 1 "NONE"
	{ts = 0;}
	if ( ++p == pe )
		goto _test_eof104;
case 104:
#line 1 "NONE"
	{ts = p;}
#line 2685 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr173;
	goto tr172;
tr172:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st105;
st105:
	if ( ++p == pe )
		goto _test_eof105;
case 105:
#line 2699 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr174;
	goto tr172;
tr173:
#line 1 "NONE"
	{te = p+1;}
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st106;
st106:
	if ( ++p == pe )
		goto _test_eof106;
case 106:
#line 2715 "ext/c/lexer.c"
	switch( (*p) ) {
		case 47: goto st29;
		case 60: goto tr176;
	}
	goto tr174;
st29:
	if ( ++p == pe )
		goto _test_eof29;
case 29:
	if ( (*p) == 115 )
		goto st30;
	goto tr38;
st30:
	if ( ++p == pe )
		goto _test_eof30;
case 30:
	if ( (*p) == 116 )
		goto st31;
	goto tr38;
st31:
	if ( ++p == pe )
		goto _test_eof31;
case 31:
	if ( (*p) == 121 )
		goto st32;
	goto tr38;
st32:
	if ( ++p == pe )
		goto _test_eof32;
case 32:
	if ( (*p) == 108 )
		goto st33;
	goto tr38;
st33:
	if ( ++p == pe )
		goto _test_eof33;
case 33:
	if ( (*p) == 101 )
		goto st34;
	goto tr38;
st34:
	if ( ++p == pe )
		goto _test_eof34;
case 34:
	if ( (*p) == 62 )
		goto tr44;
	goto tr38;
tr176:
#line 61 "ext/ragel/base_lexer.rl"
	{
        if ( (*p) == '\n' ) lines++;
    }
	goto st107;
st107:
	if ( ++p == pe )
		goto _test_eof107;
case 107:
#line 2773 "ext/c/lexer.c"
	if ( (*p) == 60 )
		goto tr176;
	goto tr174;
	}
	_test_eof35: ( state->cs) = 35; goto _test_eof; 
	_test_eof36: ( state->cs) = 36; goto _test_eof; 
	_test_eof1: ( state->cs) = 1; goto _test_eof; 
	_test_eof2: ( state->cs) = 2; goto _test_eof; 
	_test_eof3: ( state->cs) = 3; goto _test_eof; 
	_test_eof4: ( state->cs) = 4; goto _test_eof; 
	_test_eof5: ( state->cs) = 5; goto _test_eof; 
	_test_eof6: ( state->cs) = 6; goto _test_eof; 
	_test_eof7: ( state->cs) = 7; goto _test_eof; 
	_test_eof8: ( state->cs) = 8; goto _test_eof; 
	_test_eof9: ( state->cs) = 9; goto _test_eof; 
	_test_eof37: ( state->cs) = 37; goto _test_eof; 
	_test_eof10: ( state->cs) = 10; goto _test_eof; 
	_test_eof11: ( state->cs) = 11; goto _test_eof; 
	_test_eof12: ( state->cs) = 12; goto _test_eof; 
	_test_eof13: ( state->cs) = 13; goto _test_eof; 
	_test_eof14: ( state->cs) = 14; goto _test_eof; 
	_test_eof15: ( state->cs) = 15; goto _test_eof; 
	_test_eof16: ( state->cs) = 16; goto _test_eof; 
	_test_eof38: ( state->cs) = 38; goto _test_eof; 
	_test_eof17: ( state->cs) = 17; goto _test_eof; 
	_test_eof39: ( state->cs) = 39; goto _test_eof; 
	_test_eof40: ( state->cs) = 40; goto _test_eof; 
	_test_eof41: ( state->cs) = 41; goto _test_eof; 
	_test_eof42: ( state->cs) = 42; goto _test_eof; 
	_test_eof43: ( state->cs) = 43; goto _test_eof; 
	_test_eof44: ( state->cs) = 44; goto _test_eof; 
	_test_eof18: ( state->cs) = 18; goto _test_eof; 
	_test_eof45: ( state->cs) = 45; goto _test_eof; 
	_test_eof46: ( state->cs) = 46; goto _test_eof; 
	_test_eof47: ( state->cs) = 47; goto _test_eof; 
	_test_eof19: ( state->cs) = 19; goto _test_eof; 
	_test_eof48: ( state->cs) = 48; goto _test_eof; 
	_test_eof49: ( state->cs) = 49; goto _test_eof; 
	_test_eof50: ( state->cs) = 50; goto _test_eof; 
	_test_eof51: ( state->cs) = 51; goto _test_eof; 
	_test_eof52: ( state->cs) = 52; goto _test_eof; 
	_test_eof53: ( state->cs) = 53; goto _test_eof; 
	_test_eof54: ( state->cs) = 54; goto _test_eof; 
	_test_eof55: ( state->cs) = 55; goto _test_eof; 
	_test_eof56: ( state->cs) = 56; goto _test_eof; 
	_test_eof57: ( state->cs) = 57; goto _test_eof; 
	_test_eof58: ( state->cs) = 58; goto _test_eof; 
	_test_eof59: ( state->cs) = 59; goto _test_eof; 
	_test_eof60: ( state->cs) = 60; goto _test_eof; 
	_test_eof61: ( state->cs) = 61; goto _test_eof; 
	_test_eof62: ( state->cs) = 62; goto _test_eof; 
	_test_eof63: ( state->cs) = 63; goto _test_eof; 
	_test_eof64: ( state->cs) = 64; goto _test_eof; 
	_test_eof65: ( state->cs) = 65; goto _test_eof; 
	_test_eof66: ( state->cs) = 66; goto _test_eof; 
	_test_eof67: ( state->cs) = 67; goto _test_eof; 
	_test_eof68: ( state->cs) = 68; goto _test_eof; 
	_test_eof69: ( state->cs) = 69; goto _test_eof; 
	_test_eof70: ( state->cs) = 70; goto _test_eof; 
	_test_eof71: ( state->cs) = 71; goto _test_eof; 
	_test_eof72: ( state->cs) = 72; goto _test_eof; 
	_test_eof73: ( state->cs) = 73; goto _test_eof; 
	_test_eof74: ( state->cs) = 74; goto _test_eof; 
	_test_eof75: ( state->cs) = 75; goto _test_eof; 
	_test_eof76: ( state->cs) = 76; goto _test_eof; 
	_test_eof77: ( state->cs) = 77; goto _test_eof; 
	_test_eof78: ( state->cs) = 78; goto _test_eof; 
	_test_eof79: ( state->cs) = 79; goto _test_eof; 
	_test_eof80: ( state->cs) = 80; goto _test_eof; 
	_test_eof81: ( state->cs) = 81; goto _test_eof; 
	_test_eof82: ( state->cs) = 82; goto _test_eof; 
	_test_eof83: ( state->cs) = 83; goto _test_eof; 
	_test_eof84: ( state->cs) = 84; goto _test_eof; 
	_test_eof85: ( state->cs) = 85; goto _test_eof; 
	_test_eof86: ( state->cs) = 86; goto _test_eof; 
	_test_eof87: ( state->cs) = 87; goto _test_eof; 
	_test_eof20: ( state->cs) = 20; goto _test_eof; 
	_test_eof88: ( state->cs) = 88; goto _test_eof; 
	_test_eof89: ( state->cs) = 89; goto _test_eof; 
	_test_eof90: ( state->cs) = 90; goto _test_eof; 
	_test_eof91: ( state->cs) = 91; goto _test_eof; 
	_test_eof92: ( state->cs) = 92; goto _test_eof; 
	_test_eof93: ( state->cs) = 93; goto _test_eof; 
	_test_eof94: ( state->cs) = 94; goto _test_eof; 
	_test_eof21: ( state->cs) = 21; goto _test_eof; 
	_test_eof95: ( state->cs) = 95; goto _test_eof; 
	_test_eof96: ( state->cs) = 96; goto _test_eof; 
	_test_eof97: ( state->cs) = 97; goto _test_eof; 
	_test_eof98: ( state->cs) = 98; goto _test_eof; 
	_test_eof99: ( state->cs) = 99; goto _test_eof; 
	_test_eof100: ( state->cs) = 100; goto _test_eof; 
	_test_eof101: ( state->cs) = 101; goto _test_eof; 
	_test_eof102: ( state->cs) = 102; goto _test_eof; 
	_test_eof22: ( state->cs) = 22; goto _test_eof; 
	_test_eof23: ( state->cs) = 23; goto _test_eof; 
	_test_eof24: ( state->cs) = 24; goto _test_eof; 
	_test_eof25: ( state->cs) = 25; goto _test_eof; 
	_test_eof26: ( state->cs) = 26; goto _test_eof; 
	_test_eof27: ( state->cs) = 27; goto _test_eof; 
	_test_eof28: ( state->cs) = 28; goto _test_eof; 
	_test_eof103: ( state->cs) = 103; goto _test_eof; 
	_test_eof104: ( state->cs) = 104; goto _test_eof; 
	_test_eof105: ( state->cs) = 105; goto _test_eof; 
	_test_eof106: ( state->cs) = 106; goto _test_eof; 
	_test_eof29: ( state->cs) = 29; goto _test_eof; 
	_test_eof30: ( state->cs) = 30; goto _test_eof; 
	_test_eof31: ( state->cs) = 31; goto _test_eof; 
	_test_eof32: ( state->cs) = 32; goto _test_eof; 
	_test_eof33: ( state->cs) = 33; goto _test_eof; 
	_test_eof34: ( state->cs) = 34; goto _test_eof; 
	_test_eof107: ( state->cs) = 107; goto _test_eof; 

	_test_eof: {}
	if ( p == eof )
	{
	switch ( ( state->cs) ) {
	case 36: goto tr47;
	case 1: goto tr0;
	case 2: goto tr0;
	case 3: goto tr0;
	case 4: goto tr0;
	case 5: goto tr0;
	case 6: goto tr0;
	case 7: goto tr0;
	case 8: goto tr0;
	case 9: goto tr0;
	case 37: goto tr52;
	case 10: goto tr0;
	case 11: goto tr0;
	case 12: goto tr0;
	case 13: goto tr0;
	case 14: goto tr0;
	case 15: goto tr0;
	case 16: goto tr0;
	case 38: goto tr20;
	case 17: goto tr20;
	case 39: goto tr54;
	case 40: goto tr54;
	case 41: goto tr54;
	case 43: goto tr59;
	case 44: goto tr59;
	case 18: goto tr22;
	case 46: goto tr63;
	case 47: goto tr63;
	case 19: goto tr24;
	case 49: goto tr67;
	case 50: goto tr67;
	case 52: goto tr71;
	case 54: goto tr74;
	case 56: goto tr77;
	case 58: goto tr89;
	case 59: goto tr90;
	case 60: goto tr91;
	case 61: goto tr91;
	case 62: goto tr91;
	case 63: goto tr91;
	case 64: goto tr91;
	case 65: goto tr91;
	case 66: goto tr91;
	case 67: goto tr91;
	case 68: goto tr91;
	case 69: goto tr91;
	case 71: goto tr106;
	case 72: goto tr108;
	case 74: goto tr111;
	case 76: goto tr116;
	case 78: goto tr123;
	case 80: goto tr126;
	case 83: goto tr138;
	case 84: goto tr140;
	case 85: goto tr141;
	case 86: goto tr141;
	case 87: goto tr144;
	case 20: goto tr26;
	case 88: goto tr144;
	case 90: goto tr154;
	case 91: goto tr155;
	case 92: goto tr156;
	case 93: goto tr156;
	case 94: goto tr159;
	case 21: goto tr28;
	case 95: goto tr159;
	case 97: goto tr163;
	case 98: goto tr163;
	case 99: goto tr163;
	case 101: goto tr169;
	case 102: goto tr169;
	case 22: goto tr30;
	case 23: goto tr30;
	case 24: goto tr30;
	case 25: goto tr30;
	case 26: goto tr30;
	case 27: goto tr30;
	case 28: goto tr30;
	case 103: goto tr169;
	case 105: goto tr174;
	case 106: goto tr174;
	case 29: goto tr38;
	case 30: goto tr38;
	case 31: goto tr38;
	case 32: goto tr38;
	case 33: goto tr38;
	case 34: goto tr38;
	case 107: goto tr174;
	}
	}

	_out: {}
	}

#line 132 "ext/c/lexer.rl"

    state->lines = lines;

    return Qnil;
}

/**
 * Resets the internal state of the lexer.
 */
VALUE oga_xml_lexer_reset(VALUE self)
{
    OgaLexerState *state;

    Data_Get_Struct(self, OgaLexerState, state);

    state->act   = 0;
    state->cs    = c_lexer_start;
    state->lines = 0;
    state->top   = 0;

    return Qnil;
}

/**
 * Frees the associated lexer state struct.
 */
void oga_xml_lexer_free(void *state)
{
    free((OgaLexerState *) state);
}

/**
 * Allocates and wraps the C lexer state struct. This state is used to keep
 * track of the current position, line numbers, etc.
 */
VALUE oga_xml_lexer_allocate(VALUE klass)
{
    OgaLexerState *state = malloc(sizeof(OgaLexerState));

    return Data_Wrap_Struct(klass, NULL, oga_xml_lexer_free, state);
}


#line 181 "ext/c/lexer.rl"


void Init_liboga_xml_lexer()
{
    VALUE mOga   = rb_const_get(rb_cObject, rb_intern("Oga"));
    VALUE mXML   = rb_const_get(mOga, rb_intern("XML"));
    VALUE cLexer = rb_define_class_under(mXML, "Lexer", rb_cObject);

    id_advance_line  = rb_intern("advance_line");
    id_html_script_p = rb_intern("html_script?");
    id_html_style_p  = rb_intern("html_style?");
    id_html_p        = rb_intern("html?");

    rb_define_method(cLexer, "advance_native", oga_xml_lexer_advance, 1);
    rb_define_method(cLexer, "reset_native", oga_xml_lexer_reset, 0);

    rb_define_alloc_func(cLexer, oga_xml_lexer_allocate);
}
