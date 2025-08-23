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

%%machine c_lexer;

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

%% write data;

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

    %% write exec;

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

%%{
    include base_lexer "base_lexer.rl";

    variable top state->top;
    variable stack state->stack;
    variable act state->act;
    variable cs state->cs;
}%%

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
