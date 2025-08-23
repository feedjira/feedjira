/* sax.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <sys/types.h>
#if HAVE_SYS_UIO_H
#include <sys/uio.h>
#endif
#include <time.h>
#include <unistd.h>

#include "intern.h"
#include "ox.h"
#include "ruby.h"
#include "ruby/encoding.h"
#include "sax.h"
#include "sax_buf.h"
#include "sax_stack.h"
#include "special.h"

#define NAME_MISMATCH 1

#define START_STATE 1
#define BODY_STATE 2
#define AFTER_STATE 3

// error prefixes
#define BAD_BOM "Bad BOM: "
#define NO_TERM "Not Terminated: "
#define INVALID_FORMAT "Invalid Format: "
#define CASE_ERROR "Case Error: "
#define OUT_OF_ORDER "Out of Order: "
#define WRONG_CHAR "Unexpected Character: "
#define EL_MISMATCH "Start End Mismatch: "
#define INV_ELEMENT "Invalid Element: "

#define UTF8_STR "UTF-8"

static void sax_drive_init(SaxDrive dr, VALUE handler, VALUE io, SaxOptions options);
static void parse(SaxDrive dr);
// All read functions should return the next character after the 'thing' that was read and leave dr->cur one after that.
static char read_instruction(SaxDrive dr);
static char read_doctype(SaxDrive dr);
static char read_cdata(SaxDrive dr);
static char read_comment(SaxDrive dr);
static char read_element_start(SaxDrive dr);
static char read_element_end(SaxDrive dr);
static char read_text(SaxDrive dr);
static char read_jump(SaxDrive dr, const char *pat);
static char read_attrs(SaxDrive dr, char c, char termc, char term2, int is_xml, int eq_req, Hint h);
static char read_name_token(SaxDrive dr);
static char read_quoted_value(SaxDrive dr, bool inst);

static void hint_clear_empty(SaxDrive dr);
static Nv   hint_try_close(SaxDrive dr, const char *name);

VALUE ox_sax_value_class = Qnil;

const rb_data_type_t ox_sax_value_type = {
    "Ox/Sax/Value",
    {
        NULL,
        NULL,
        NULL,
    },
    0,
    0,
};

static VALUE protect_parse(VALUE drp) {
    parse((SaxDrive)drp);

    return Qnil;
}

VALUE
str2sym(SaxDrive dr, const char *str, size_t len, const char **strp) {
    VALUE sym;

    if (dr->options.symbolize) {
        sym = ox_sym_intern(str, len, strp);
    } else {
        sym = dr->get_name(str, len, dr->encoding, strp);
    }
    return sym;
}

void ox_sax_parse(VALUE handler, VALUE io, SaxOptions options) {
#if HAVE_RB_EXT_RACTOR_SAFE
    rb_ext_ractor_safe(true);
#endif
    struct _saxDrive dr;
    int              line = 0;

    sax_drive_init(&dr, handler, io, options);
    rb_protect(protect_parse, (VALUE)&dr, &line);
    ox_sax_drive_cleanup(&dr);
    if (0 != line) {
        rb_jump_tag(line);
    }
}

static void set_long_noop(VALUE handler, long pos) {
}

static void set_pos(VALUE handler, long pos) {
    rb_ivar_set(handler, ox_at_pos_id, LONG2NUM(pos));
}

static void set_line(VALUE handler, long line) {
    rb_ivar_set(handler, ox_at_line_id, LONG2NUM(line));
}

static void set_col(VALUE handler, long col) {
    rb_ivar_set(handler, ox_at_column_id, LONG2NUM(col));
}

static void attr_noop(SaxDrive dr, VALUE name, char *value, long pos, long line, long col) {
}

static void attr_text(SaxDrive dr, VALUE name, char *value, long pos, long line, long col) {
    VALUE args[2];

    args[0] = name;
    if (dr->options.convert_special && '\0' != value[0]) {
        ox_sax_collapse_special(dr, value, pos, line, col);
    }
    args[1] = rb_str_new2(value);
    if (0 != dr->encoding) {
        rb_enc_associate(args[1], dr->encoding);
    }
    dr->set_pos(dr->handler, pos);
    dr->set_line(dr->handler, line);
    dr->set_col(dr->handler, col);
    rb_funcall2(dr->handler, ox_attr_id, 2, args);
}

static void attr_value(SaxDrive dr, VALUE name, char *value, long pos, long line, long col) {
    VALUE args[2];

    dr->set_pos(dr->handler, pos);
    dr->set_line(dr->handler, line);
    dr->set_col(dr->handler, col);
    args[0] = name;
    args[1] = dr->value_obj;
    rb_funcall2(dr->handler, ox_attr_value_id, 2, args);
}

static void attrs_done_noop(VALUE handler) {
}

static void attrs_done(VALUE handler) {
    rb_funcall(handler, ox_attrs_done_id, 0);
}

static VALUE instruct_noop(SaxDrive dr, const char *target, long pos, long line, long col) {
    return Qnil;
}

static VALUE instruct(SaxDrive dr, const char *target, long pos, long line, long col) {
    VALUE arg = rb_str_new2(target);

    dr->set_pos(dr->handler, pos);
    dr->set_line(dr->handler, line);
    dr->set_col(dr->handler, col);
    rb_funcall(dr->handler, ox_instruct_id, 1, arg);

    return arg;
}

static VALUE instruct_just_value(SaxDrive dr, const char *target, long pos, long line, long col) {
    return rb_str_new2(target);
}

static void end_instruct_noop(SaxDrive dr, VALUE target, long pos, long line, long col) {
}

static void end_instruct(SaxDrive dr, VALUE target, long pos, long line, long col) {
    dr->set_pos(dr->handler, pos);
    dr->set_line(dr->handler, line);
    dr->set_col(dr->handler, col);
    rb_funcall(dr->handler, ox_end_instruct_id, 1, target);
}

static void dr_loc_noop(SaxDrive dr, long pos, long line, long col) {
}

static void comment(SaxDrive dr, long pos, long line, long col) {
    if (!dr->blocked) {
        Nv   parent = stack_peek(&dr->stack);
        Hint h      = ox_hint_find(dr->options.hints, "!--");

        if (NULL == parent || NULL == parent->hint || OffOverlay != parent->hint->overlay ||
            (NULL != h && (ActiveOverlay == h->overlay || ActiveOverlay == h->overlay))) {
            VALUE arg = rb_str_new2(dr->buf.str);

            if (0 != dr->encoding) {
                rb_enc_associate(arg, dr->encoding);
            }
            dr->set_pos(dr->handler, pos);
            dr->set_line(dr->handler, line);
            dr->set_col(dr->handler, col);
            rb_funcall(dr->handler, ox_comment_id, 1, arg);
        }
    }
}

static void cdata(SaxDrive dr, long pos, long line, long col) {
    Nv parent = stack_peek(&dr->stack);

    if (!dr->blocked && (NULL == parent || NULL == parent->hint || OffOverlay != parent->hint->overlay)) {
        VALUE arg = rb_str_new2(dr->buf.str);

        if (0 != dr->encoding) {
            rb_enc_associate(arg, dr->encoding);
        }
        dr->set_pos(dr->handler, pos);
        dr->set_line(dr->handler, line);
        dr->set_col(dr->handler, col);
        rb_funcall(dr->handler, ox_cdata_id, 1, arg);
    }
}

static void doctype(SaxDrive dr, long pos, long line, long col) {
    dr->set_pos(dr->handler, pos);
    dr->set_line(dr->handler, line);
    dr->set_col(dr->handler, col);
    rb_funcall(dr->handler, ox_doctype_id, 1, rb_str_new2(dr->buf.str));
}

static void error_noop(SaxDrive dr, const char *msg, long pos, long line, long col) {
}

static void error(SaxDrive dr, const char *msg, long pos, long line, long col) {
    VALUE args[3];

    args[0] = rb_str_new2(msg);
    args[1] = LONG2NUM(line);
    args[2] = LONG2NUM(col);
    dr->set_pos(dr->handler, pos);
    dr->set_line(dr->handler, line);
    dr->set_col(dr->handler, col);
    rb_funcall2(dr->handler, ox_error_id, 3, args);
}

static void end_element_cb(SaxDrive dr, VALUE name, long pos, long line, long col, Hint h) {
    if (dr->has_end_element && 0 >= dr->blocked &&
        (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
        dr->set_pos(dr->handler, pos);
        dr->set_line(dr->handler, line);
        dr->set_col(dr->handler, col);
        rb_funcall(dr->handler, ox_end_element_id, 1, name);
    }
    if (NULL != h && BlockOverlay == h->overlay && 0 < dr->blocked) {
        dr->blocked--;
    }
}

static void sax_drive_init(SaxDrive dr, VALUE handler, VALUE io, SaxOptions options) {
    ox_sax_buf_init(&dr->buf, io);
    dr->buf.dr = dr;
    stack_init(&dr->stack);
    dr->handler   = handler;
    dr->value_obj = TypedData_Wrap_Struct(ox_sax_value_class, &ox_sax_value_type, dr);
    rb_gc_register_address(&dr->value_obj);
    dr->options = *options;
    dr->err     = 0;
    dr->blocked = 0;
    dr->abort   = false;

    dr->set_pos  = (Qtrue == rb_ivar_defined(handler, ox_at_pos_id)) ? set_pos : set_long_noop;
    dr->set_line = (Qtrue == rb_ivar_defined(handler, ox_at_line_id)) ? set_line : set_long_noop;
    dr->set_col  = (Qtrue == rb_ivar_defined(handler, ox_at_column_id)) ? set_col : set_long_noop;
    if (rb_respond_to(handler, ox_attr_value_id)) {
        dr->attr_cb        = attr_value;
        dr->want_attr_name = true;
    } else if (rb_respond_to(handler, ox_attr_id)) {
        dr->attr_cb        = attr_text;
        dr->want_attr_name = true;
    } else {
        dr->attr_cb        = attr_noop;
        dr->want_attr_name = false;
    }
    dr->attrs_done   = rb_respond_to(handler, ox_attrs_done_id) ? attrs_done : attrs_done_noop;
    dr->instruct     = rb_respond_to(handler, ox_instruct_id) ? instruct : instruct_noop;
    dr->end_instruct = rb_respond_to(handler, ox_end_instruct_id) ? end_instruct : end_instruct_noop;
    if (rb_respond_to(handler, ox_end_instruct_id) && !rb_respond_to(handler, ox_instruct_id)) {
        dr->instruct = instruct_just_value;
    }
    dr->doctype = rb_respond_to(handler, ox_doctype_id) ? doctype : dr_loc_noop;
    dr->comment = rb_respond_to(handler, ox_comment_id) ? comment : dr_loc_noop;
    dr->cdata   = rb_respond_to(handler, ox_cdata_id) ? cdata : dr_loc_noop;
    dr->error   = rb_respond_to(handler, ox_error_id) ? error : error_noop;

    dr->has_text          = rb_respond_to(handler, ox_text_id);
    dr->has_value         = rb_respond_to(handler, ox_value_id);
    dr->has_start_element = rb_respond_to(handler, ox_start_element_id);
    dr->has_end_element   = rb_respond_to(handler, ox_end_element_id);

    if ('\0' == *ox_default_options.encoding) {
        VALUE encoding;

        dr->encoding = 0;
        if (rb_respond_to(io, ox_external_encoding_id) &&
            Qnil != (encoding = rb_funcall(io, ox_external_encoding_id, 0))) {
            int e = rb_enc_get_index(encoding);
            if (0 <= e) {
                dr->encoding = rb_enc_from_index(e);
            }
        }
    } else {
        dr->encoding = rb_enc_find(ox_default_options.encoding);
    }
    dr->utf8 = (NULL == dr->encoding || rb_utf8_encoding() == dr->encoding);
    if (NULL == dr->encoding || rb_utf8_encoding() == dr->encoding) {       // UTF-8
        dr->get_name = dr->options.symbolize ? ox_utf8_sym : ox_utf8_name;  // TBD UTF8 sym?
    } else {
        dr->get_name = dr->options.symbolize ? ox_enc_sym : ox_enc_name;
    }
}

void ox_sax_drive_cleanup(SaxDrive dr) {
    rb_gc_unregister_address(&dr->value_obj);
    buf_cleanup(&dr->buf);
    stack_cleanup(&dr->stack);
}

static void ox_sax_drive_error_at(SaxDrive dr, const char *msg, off_t pos, off_t line, off_t col) {
    dr->error(dr, msg, pos, line, col);
}

void ox_sax_drive_error(SaxDrive dr, const char *msg) {
    ox_sax_drive_error_at(dr, msg, dr->buf.pos, dr->buf.line, dr->buf.col);
}

static char skipBOM(SaxDrive dr) {
    char c = buf_get(&dr->buf);

    if (0xEF == (uint8_t)c) { /* only UTF8 is supported */
        if (0xBB == (uint8_t)buf_get(&dr->buf) && 0xBF == (uint8_t)buf_get(&dr->buf)) {
            dr->encoding = ox_utf8_encoding;
            c            = buf_get(&dr->buf);
        } else {
            ox_sax_drive_error(dr, BAD_BOM "invalid BOM or a binary file.");
            c = '\0';
        }
    }
    return c;
}

static void parse(SaxDrive dr) {
    char c     = skipBOM(dr);
    int  state = START_STATE;
    Nv   parent;

    while ('\0' != c) {
        buf_protect(&dr->buf);
        if ('<' == c) {
            c = buf_get(&dr->buf);
            switch (c) {
            case '?': /* instructions (xml or otherwise) */ c = read_instruction(dr); break;
            case '!': /* comment or doctype */
                buf_protect(&dr->buf);
                c = buf_get(&dr->buf);
                if ('\0' == c) {
                    ox_sax_drive_error(dr, NO_TERM "DOCTYPE or comment not terminated");

                    goto DONE;
                } else if ('-' == c) {
                    c = buf_get(&dr->buf); /* skip first - and get next character */
                    if ('-' != c) {
                        ox_sax_drive_error(dr, INVALID_FORMAT "bad comment format, expected <!--");
                    } else {
                        c = buf_get(&dr->buf); /* skip second - */
                    }
                    c = read_comment(dr);
                } else {
                    int   i;
                    int   spaced = 0;
                    off_t pos    = dr->buf.pos + 1;
                    off_t line   = dr->buf.line;
                    off_t col    = dr->buf.col + 1;

                    if (is_white(c)) {
                        spaced = 1;
                        c      = buf_next_non_white(&dr->buf);
                    }
                    dr->buf.str = dr->buf.tail - 1;
                    for (i = 7; 0 < i; i--) {
                        c = buf_get(&dr->buf);
                    }
                    if (0 == strncmp("DOCTYPE", dr->buf.str, 7)) {
                        if (spaced) {
                            ox_sax_drive_error_at(dr, WRONG_CHAR "<!DOCTYPE can not included spaces", pos, line, col);
                        }
                        if (START_STATE != state) {
                            ox_sax_drive_error(dr, OUT_OF_ORDER "DOCTYPE can not come after an element");
                        }
                        c = read_doctype(dr);
                    } else if (0 == strncasecmp("DOCTYPE", dr->buf.str, 7)) {
                        if (!dr->options.smart) {
                            ox_sax_drive_error(dr, CASE_ERROR "expected DOCTYPE all in caps");
                        }
                        if (START_STATE != state) {
                            ox_sax_drive_error(dr, OUT_OF_ORDER "DOCTYPE can not come after an element");
                        }
                        c = read_doctype(dr);
                    } else if (0 == strncmp("[CDATA[", dr->buf.str, 7)) {
                        if (spaced) {
                            ox_sax_drive_error_at(dr, WRONG_CHAR "<![CDATA[ can not included spaces", pos, line, col);
                        }
                        c = read_cdata(dr);
                    } else if (0 == strncasecmp("[CDATA[", dr->buf.str, 7)) {
                        if (!dr->options.smart) {
                            ox_sax_drive_error(dr, CASE_ERROR "expected CDATA all in caps");
                        }
                        c = read_cdata(dr);
                    } else {
                        Nv parent = stack_peek(&dr->stack);

                        if (0 != parent) {
                            parent->childCnt++;
                        }
                        ox_sax_drive_error_at(dr, WRONG_CHAR "DOCTYPE, CDATA, or comment expected", pos, line, col);
                        c = read_name_token(dr);
                        if ('>' == c) {
                            c = buf_get(&dr->buf);
                        }
                    }
                }
                break;
            case '/': /* element end */
                parent = stack_peek(&dr->stack);
                if (0 != parent && 0 == parent->childCnt && dr->has_text && !dr->blocked) {
                    VALUE args[1];
                    args[0] = rb_str_new2("");
                    if (0 != dr->encoding) {
                        rb_enc_associate(args[0], dr->encoding);
                    }
                    dr->set_pos(dr->handler, dr->buf.pos);
                    dr->set_line(dr->handler, dr->buf.line);
                    dr->set_col(dr->handler, dr->buf.col);
                    rb_funcall2(dr->handler, ox_text_id, 1, args);
                }
                c = read_element_end(dr);
                if (0 == stack_peek(&dr->stack)) {
                    state = AFTER_STATE;
                }
                break;
            case '\0': goto DONE;
            default:
                buf_backup(&dr->buf);
                if (AFTER_STATE == state) {
                    ox_sax_drive_error(dr, OUT_OF_ORDER "multiple top level elements");
                }
                state = BODY_STATE;
                c     = read_element_start(dr);
                if (0 == stack_peek(&dr->stack)) {
                    state = AFTER_STATE;
                }
                break;
            }
        } else {
            buf_reset(&dr->buf);
            c = read_text(dr);
        }
    }
DONE:
    if (dr->abort) {
        return;
    }
    if (dr->stack.head < dr->stack.tail) {
        char msg[256];
        Nv   sp;

        for (sp = dr->stack.tail - 1; dr->stack.head <= sp; sp--) {
            snprintf(msg, sizeof(msg) - 1, "%selement '%s' not closed", EL_MISMATCH, nv_name(sp));
            ox_sax_drive_error_at(dr, msg, dr->buf.pos, dr->buf.line, dr->buf.col);
            end_element_cb(dr, sp->val, dr->buf.pos, dr->buf.line, dr->buf.col, sp->hint);
        }
    }
}

static void read_content(SaxDrive dr, char *content, size_t len) {
    char  c;
    char *end = content + len;

    while ('\0' != (c = buf_get(&dr->buf))) {
        if (end <= content) {
            *content = '\0';
            ox_sax_drive_error(dr, "processing instruction content too large");
            return;
        }
        if ('?' == c) {
            if ('\0' == (c = buf_get(&dr->buf))) {
                ox_sax_drive_error(dr, NO_TERM "document not terminated");
            }
            if ('>' == c) {
                *content = '\0';
                return;
            } else {
                *content++ = c;
            }
        } else {
            *content++ = c;
        }
    }
    *content = '\0';
}

/* Entered after the "<?" sequence. Ready to read the rest.
 */
static char read_instruction(SaxDrive dr) {
    char  content[4096];
    char  c;
    int   coff;
    VALUE target = Qnil;
    int   is_xml;
    off_t pos  = dr->buf.pos - 1;
    off_t line = dr->buf.line;
    off_t col  = dr->buf.col - 1;

    buf_protect(&dr->buf);
    if ('\0' == (c = read_name_token(dr))) {
        return c;
    }
    is_xml = (0 == (dr->options.smart ? strcasecmp("xml", dr->buf.str) : strcmp("xml", dr->buf.str)));

    target = dr->instruct(dr, dr->buf.str, pos, line, col);
    buf_protect(&dr->buf);
    pos  = dr->buf.pos;
    line = dr->buf.line;
    col  = dr->buf.col;
    read_content(dr, content, sizeof(content) - 1);
    coff = (int)(dr->buf.tail - dr->buf.head);
    buf_reset(&dr->buf);
    dr->err = 0;
    c       = read_attrs(dr, c, '?', '?', is_xml, 1, NULL);
    dr->attrs_done(dr->handler);
    if (dr->err) {
        if (dr->has_text) {
            VALUE args[1];

            if (dr->options.convert_special) {
                ox_sax_collapse_special(dr, content, (int)pos, (int)line, (int)col);
            }
            args[0] = rb_str_new2(content);
            if (0 != dr->encoding) {
                rb_enc_associate(args[0], dr->encoding);
            }
            dr->set_pos(dr->handler, pos);
            dr->set_line(dr->handler, line);
            dr->set_col(dr->handler, col);
            rb_funcall2(dr->handler, ox_text_id, 1, args);
        }
        dr->buf.tail = dr->buf.head + coff;
        c            = buf_get(&dr->buf);
    } else {
        pos  = dr->buf.pos;
        line = dr->buf.line;
        col  = dr->buf.col;
        c    = buf_next_non_white(&dr->buf);
        if ('>' == c) {
            c = buf_get(&dr->buf);
        } else {
            ox_sax_drive_error_at(dr, NO_TERM "instruction not terminated", pos, line, col);
            if ('>' == c) {
                c = buf_get(&dr->buf);
            }
        }
    }
    dr->end_instruct(dr, target, pos, line, col);
    dr->buf.str = NULL;

    return c;
}

static char read_delimited(SaxDrive dr, char end) {
    char c;

    if ('"' == end || '\'' == end) {
        while (end != (c = buf_get(&dr->buf))) {
            if ('\0' == c) {
                ox_sax_drive_error(dr, NO_TERM "doctype not terminated");
                return c;
            }
        }
    } else {
        while (1) {
            c = buf_get(&dr->buf);
            if (end == c) {
                return c;
            }
            switch (c) {
            case '\0': ox_sax_drive_error(dr, NO_TERM "doctype not terminated"); return c;
            case '"': c = read_delimited(dr, c); break;
            case '\'': c = read_delimited(dr, c); break;
            case '[': c = read_delimited(dr, ']'); break;
            case '<': c = read_delimited(dr, '>'); break;
            default: break;
            }
        }
    }
    return c;
}

/* Entered after the "<!DOCTYPE " sequence. Ready to read the rest.
 */
static char read_doctype(SaxDrive dr) {
    long  pos  = (long)(dr->buf.pos - 9);
    long  line = (long)(dr->buf.line);
    long  col  = (long)(dr->buf.col - 9);
    char *s;
    Nv    parent = stack_peek(&dr->stack);

    buf_backup(&dr->buf); /* back up to the start in case the doctype is empty */
    buf_protect(&dr->buf);
    read_delimited(dr, '>');
    if (dr->options.smart && 0 == dr->options.hints) {
        for (s = dr->buf.str; is_white(*s); s++) {
        }
        if (0 == strncasecmp("HTML", s, 4)) {
            dr->options.hints = ox_hints_html();
        }
    }
    *(dr->buf.tail - 1) = '\0';
    if (0 != parent) {
        parent->childCnt++;
    }
    dr->doctype(dr, pos, line, col);
    dr->buf.str = 0;

    return buf_get(&dr->buf);
}

/* Entered after the "<![CDATA[" sequence. Ready to read the rest.
 */
static char read_cdata(SaxDrive dr) {
    char            c;
    char            zero   = '\0';
    int             end    = 0;
    long            pos    = (long)(dr->buf.pos - 9);
    long            line   = (long)(dr->buf.line);
    long            col    = (long)(dr->buf.col - 9);
    struct _checkPt cp     = CHECK_PT_INIT;
    Nv              parent = stack_peek(&dr->stack);

    // TBD check parent overlay
    if (0 != parent) {
        parent->childCnt++;
    }
    buf_backup(&dr->buf); /* back up to the start in case the cdata is empty */
    buf_protect(&dr->buf);
    while (1) {
        c = buf_get(&dr->buf);
        switch (c) {
        case ']': end++; break;
        case '>':
            if (2 <= end) {
                *(dr->buf.tail - 3) = '\0';
                c                   = buf_get(&dr->buf);
                goto CB;
            }
            if (!buf_checkset(&cp)) {
                buf_checkpoint(&dr->buf, &cp);
            }
            end = 0;
            break;
        case '<':
            if (!buf_checkset(&cp)) {
                buf_checkpoint(&dr->buf, &cp);
            }
            end = 0;
            break;
        case '\0':
            if (buf_checkset(&cp)) {
                c = buf_checkback(&dr->buf, &cp);
                ox_sax_drive_error(dr, NO_TERM "CDATA not terminated");
                zero                = c;
                *(dr->buf.tail - 1) = '\0';
                goto CB;
            }
            ox_sax_drive_error(dr, NO_TERM "CDATA not terminated");
            return '\0';
        default:
            if (1 < end && !buf_checkset(&cp)) {
                buf_checkpoint(&dr->buf, &cp);
            }
            end = 0;
            break;
        }
    }
CB:
    dr->cdata(dr, pos, line, col);
    if ('\0' != zero) {
        *(dr->buf.tail - 1) = zero;
    }
    dr->buf.str = 0;

    return c;
}

/* Entered after the "<!--" sequence. Ready to read the rest.
 */
static char read_comment(SaxDrive dr) {
    char            c;
    char            zero = '\0';
    int             end  = 0;
    long            pos  = (long)(dr->buf.pos - 4);
    long            line = (long)(dr->buf.line);
    long            col  = (long)(dr->buf.col - 4);
    struct _checkPt cp   = CHECK_PT_INIT;

    buf_backup(&dr->buf); /* back up to the start in case the cdata is empty */
    buf_protect(&dr->buf);
    while (1) {
        c = buf_get(&dr->buf);
        switch (c) {
        case '-': end++; break;
        case '>':
            if (2 <= end) {
                *(dr->buf.tail - 3) = '\0';
                c                   = buf_get(&dr->buf);
                goto CB;
            }
            if (!buf_checkset(&cp)) {
                buf_checkpoint(&dr->buf, &cp);
            }
            end = 0;
            break;
        case '<':
            if (!buf_checkset(&cp)) {
                buf_checkpoint(&dr->buf, &cp);
            }
            end = 0;
            break;
        case '\0':
            if (buf_checkset(&cp)) {
                c = buf_checkback(&dr->buf, &cp);
                ox_sax_drive_error(dr, NO_TERM "comment not terminated");
                zero                = c;
                *(dr->buf.tail - 1) = '\0';
                goto CB;
            }
            ox_sax_drive_error(dr, NO_TERM "comment not terminated");
            return '\0';
        default:
            if (1 < end && !buf_checkset(&cp)) {
                buf_checkpoint(&dr->buf, &cp);
            }
            end = 0;
            break;
        }
    }
CB:
    dr->comment(dr, pos, line, col);
    if ('\0' != zero) {
        *(dr->buf.tail - 1) = zero;
    }
    dr->buf.str = 0;

    return c;
}

/* Entered after the '<' and the first character after that. Returns status
 * code.
 */
static char read_element_start(SaxDrive dr) {
    const char    *ename = NULL;
    char           ebuf[128];
    size_t         nlen;
    volatile VALUE name = Qnil;
    char           c;
    long           pos       = (long)(dr->buf.pos);
    long           line      = (long)(dr->buf.line);
    long           col       = (long)(dr->buf.col);
    Hint           h         = NULL;
    int            stackless = 0;
    Nv             parent    = stack_peek(&dr->stack);
    bool           closed;
    bool           efree = false;

    if ('\0' == (c = read_name_token(dr))) {
        return '\0';
    }
    if ('\0' == *dr->buf.str) {
        char msg[256];

        snprintf(msg, sizeof(msg) - 1, "%sempty element", INVALID_FORMAT);
        ox_sax_drive_error_at(dr, msg, pos, line, col);

        return buf_get(&dr->buf);
    }
    if (0 != parent) {
        parent->childCnt++;
    }
    if (dr->options.smart && 0 == dr->options.hints && stack_empty(&dr->stack) &&
        0 == strcasecmp("html", dr->buf.str)) {
        dr->options.hints = ox_hints_html();
    }
    nlen = dr->buf.tail - dr->buf.str - 1;
    if (NULL != dr->options.hints) {
        hint_clear_empty(dr);
        h = ox_hint_find(dr->options.hints, dr->buf.str);
        if (NULL == h) {
            char msg[256];

            snprintf(msg,
                     sizeof(msg),
                     "%s%s is not a valid element type for a %s document type.",
                     INV_ELEMENT,
                     dr->buf.str,
                     dr->options.hints->name);
            ox_sax_drive_error(dr, msg);
        } else {
            Nv top_nv = stack_peek(&dr->stack);

            if (AbortOverlay == h->overlay) {
                if (rb_respond_to(dr->handler, ox_abort_id)) {
                    VALUE args[1];

                    args[0] = str2sym(dr, dr->buf.str, nlen, NULL);
                    rb_funcall2(dr->handler, ox_abort_id, 1, args);
                }
                dr->abort = true;
                return '\0';
            }
            if (BlockOverlay == h->overlay) {
                dr->blocked++;
            }
            if (h->empty) {
                stackless = 1;
            }
            if (0 != top_nv) {
                char msg[256];

                if (!h->nest && NestOverlay != h->overlay && nv_same_name(top_nv, h->name, true)) {
                    snprintf(msg,
                             sizeof(msg) - 1,
                             "%s%s can not be nested in a %s document, closing previous.",
                             INV_ELEMENT,
                             dr->buf.str,
                             dr->options.hints->name);
                    ox_sax_drive_error(dr, msg);
                    stack_pop(&dr->stack);
                    end_element_cb(dr, top_nv->val, pos, line, col, top_nv->hint);
                    top_nv = stack_peek(&dr->stack);
                }
                if (NULL != top_nv && 0 != h->parents && NestOverlay != h->overlay) {
                    const char **p;
                    int          ok = 0;

                    for (p = h->parents; 0 != *p; p++) {
                        if (nv_same_name(top_nv, *p, true)) {
                            ok = 1;
                            break;
                        }
                    }
                    if (!ok) {
                        snprintf(msg,
                                 sizeof(msg) - 1,
                                 "%s%s can not be a child of a %s in a %s document.",
                                 INV_ELEMENT,
                                 h->name,
                                 nv_name(top_nv),
                                 dr->options.hints->name);
                        ox_sax_drive_error(dr, msg);
                    }
                }
            }
        }
    }
    name = str2sym(dr, dr->buf.str, nlen, &ename);
    if (NULL == ename) {
        if (sizeof(ebuf) <= nlen) {
            ename = ox_strndup(dr->buf.str, nlen);
            efree = true;
        } else {
            memcpy(ebuf, dr->buf.str, nlen);
            ebuf[nlen] = '\0';
            ename      = ebuf;
        }
    }
    if (dr->has_start_element && 0 >= dr->blocked &&
        (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
        VALUE args[1];

        dr->set_pos(dr->handler, pos);
        dr->set_line(dr->handler, line);
        dr->set_col(dr->handler, col);
        args[0] = name;
        rb_funcall2(dr->handler, ox_start_element_id, 1, args);
    }
    if ('/' == c) {
        closed = true;
    } else if ('>' == c) {
        closed = false;
    } else {
        buf_protect(&dr->buf);
        c = read_attrs(dr, c, '/', '>', 0, 0, h);
        if (is_white(c)) {
            c = buf_next_non_white(&dr->buf);
        }
        closed = ('/' == c);
    }
    if (0 >= dr->blocked && (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
        dr->attrs_done(dr->handler);
    }
    if (closed) {
        c = buf_next_non_white(&dr->buf);

        end_element_cb(dr, name, dr->buf.pos, dr->buf.line, dr->buf.col, h);
    } else if (stackless) {
        end_element_cb(dr, name, pos, line, col, h);
    } else if (NULL != h && h->jump) {
        stack_push(&dr->stack, ename, nlen, name, h);
        if ('>' != c) {
            ox_sax_drive_error(dr, WRONG_CHAR "element not closed");
            return c;
        }
        read_jump(dr, h->name);
        return '<';
    } else {
        stack_push(&dr->stack, ename, nlen, name, h);
    }
    if (efree) {
        free((char *)ename);
    }
    if ('>' != c) {
        ox_sax_drive_error(dr, WRONG_CHAR "element not closed");
        return c;
    }
    dr->buf.str = NULL;

    return buf_get(&dr->buf);
}

static Nv stack_rev_find(SaxDrive dr, const char *name) {
    Nv nv;

    for (nv = dr->stack.tail - 1; dr->stack.head <= nv; nv--) {
        if (nv_same_name(nv, name, dr->options.smart)) {
            return nv;
        }
    }
    return 0;
}

static char read_element_end(SaxDrive dr) {
    VALUE name = Qnil;
    char  c;
    long  pos  = (long)(dr->buf.pos - 1);
    long  line = (long)(dr->buf.line);
    long  col  = (long)(dr->buf.col - 1);
    Nv    nv;
    Hint  h = NULL;

    if ('\0' == (c = read_name_token(dr))) {
        return '\0';
    }
    if (is_white(c)) {
        c = buf_next_non_white(&dr->buf);
    }
    // c should be > and current is one past so read another char
    c  = buf_get(&dr->buf);
    nv = stack_peek(&dr->stack);
    if (0 != nv && nv_same_name(nv, dr->buf.str, dr->options.smart)) {
        name = nv->val;
        h    = nv->hint;
        stack_pop(&dr->stack);
    } else {
        // Mismatched start and end
        char msg[256];
        Nv   match = stack_rev_find(dr, dr->buf.str);

        if (0 == match) {
            // Not found so open and close element.
            h = ox_hint_find(dr->options.hints, dr->buf.str);
            if (NULL != h && h->empty) {
                // Just close normally
                name = str2sym(dr, dr->buf.str, dr->buf.tail - dr->buf.str - 2, 0);
                snprintf(msg,
                         sizeof(msg) - 1,
                         "%selement '%s' should not have a separate close element",
                         EL_MISMATCH,
                         dr->buf.str);
                ox_sax_drive_error_at(dr, msg, pos, line, col);
                return c;
            } else {
                snprintf(msg, sizeof(msg) - 1, "%selement '%s' closed but not opened", EL_MISMATCH, dr->buf.str);
                ox_sax_drive_error_at(dr, msg, pos, line, col);
                if ('\x00' == *dr->buf.tail) {
                    name = str2sym(dr, dr->buf.str, dr->buf.tail - dr->buf.str - 1, 0);
                } else {
                    name = str2sym(dr, dr->buf.str, dr->buf.tail - dr->buf.str - 2, 0);
                }
                if (dr->has_start_element && 0 >= dr->blocked &&
                    (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
                    VALUE args[1];

                    dr->set_pos(dr->handler, pos);
                    dr->set_line(dr->handler, line);
                    dr->set_col(dr->handler, col);
                    args[0] = name;
                    rb_funcall2(dr->handler, ox_start_element_id, 1, args);
                }
                if (NULL != h && BlockOverlay == h->overlay && 0 < dr->blocked) {
                    dr->blocked--;
                }
            }
        } else {
            // Found a match so close all up to the found element in stack.
            Nv n2;

            if (0 != (n2 = hint_try_close(dr, dr->buf.str))) {
                name = n2->val;
                h    = n2->hint;
            } else {
                snprintf(msg,
                         sizeof(msg) - 1,
                         "%selement '%s' close does not match '%s' open",
                         EL_MISMATCH,
                         dr->buf.str,
                         nv_name(nv));
                ox_sax_drive_error_at(dr, msg, pos, line, col);
                for (nv = stack_pop(&dr->stack); match < nv; nv = stack_pop(&dr->stack)) {
                    end_element_cb(dr, nv->val, pos, line, col, nv->hint);
                }
                name = nv->val;
                h    = nv->hint;
            }
        }
    }
    end_element_cb(dr, name, pos, line, col, h);

    return c;
}

static char read_text(SaxDrive dr) {
    VALUE args[1];
    char  c;
    long  pos      = (long)(dr->buf.pos);
    long  line     = (long)(dr->buf.line);
    long  col      = (long)(dr->buf.col - 1);
    Nv    parent   = stack_peek(&dr->stack);
    int   allWhite = 1;

    buf_backup(&dr->buf);
    buf_protect(&dr->buf);
    while ('<' != (c = buf_get(&dr->buf))) {
        switch (c) {
        case ' ':
        case '\t':
        case '\f':
        case '\n':
        case '\r': break;
        case '\0':
            if (allWhite) {
                return c;
            }
            ox_sax_drive_error(dr, NO_TERM "text not terminated");
            goto END_OF_BUF;
            break;
        default: allWhite = 0; break;
        }
    }
END_OF_BUF:
    if ('\0' != c) {
        *(dr->buf.tail - 1) = '\0';
    }
    if (allWhite) {
        int isEnd = ('/' == buf_get(&dr->buf));

        buf_backup(&dr->buf);
        if (dr->has_text && ((NoSkip == dr->options.skip && !isEnd) || (OffSkip == dr->options.skip))) {
            args[0] = rb_str_new2(dr->buf.str);
            if (0 != dr->encoding) {
                rb_enc_associate(args[0], dr->encoding);
            }
            dr->set_pos(dr->handler, pos);
            dr->set_line(dr->handler, line);
            dr->set_col(dr->handler, col);
            rb_funcall2(dr->handler, ox_text_id, 1, args);
        }
        if (!isEnd || 0 == parent || 0 < parent->childCnt) {
            return c;
        }
    }
    if (0 != parent) {
        parent->childCnt++;
    }
    if (!dr->blocked && (NULL == parent || NULL == parent->hint || OffOverlay != parent->hint->overlay)) {
        if (dr->has_value) {
            dr->set_pos(dr->handler, pos);
            dr->set_line(dr->handler, line);
            dr->set_col(dr->handler, col);
            *args = dr->value_obj;
            rb_funcall2(dr->handler, ox_value_id, 1, args);
        } else if (dr->has_text) {
            if (dr->options.convert_special) {
                ox_sax_collapse_special(dr, dr->buf.str, pos, line, col);
            }
            switch (dr->options.skip) {
            case CrSkip: buf_collapse_return(dr->buf.str); break;
            case SpcSkip: buf_collapse_white(dr->buf.str); break;
            default: break;
            }
            args[0] = rb_str_new2(dr->buf.str);
            if (0 != dr->encoding) {
                rb_enc_associate(args[0], dr->encoding);
            }
            dr->set_pos(dr->handler, pos);
            dr->set_line(dr->handler, line);
            dr->set_col(dr->handler, col);
            rb_funcall2(dr->handler, ox_text_id, 1, args);
        }
    }
    dr->buf.str = 0;

    return c;
}

static int read_jump_term(Buf buf, const char *pat) {
    struct _checkPt cp;

    buf_checkpoint(buf, &cp);  // right after <
    if ('/' != buf_next_non_white(buf)) {
        return 0;
    }
    if (*pat != tolower(buf_next_non_white(buf))) {
        return 0;
    }
    for (pat++; '\0' != *pat; pat++) {
        if (*pat != tolower(buf_get(buf))) {
            return 0;
        }
    }
    if ('>' != buf_next_non_white(buf)) {
        return 0;
    }
    buf_checkback(buf, &cp);
    return 1;
}

static char read_jump(SaxDrive dr, const char *pat) {
    VALUE args[1];
    char  c;
    long  pos    = (long)(dr->buf.pos);
    long  line   = (long)(dr->buf.line);
    long  col    = (long)(dr->buf.col - 1);
    Nv    parent = stack_peek(&dr->stack);

    buf_protect(&dr->buf);
    while (1) {
        c = buf_get(&dr->buf);
        switch (c) {
        case '<':
            if (read_jump_term(&dr->buf, pat)) {
                goto END_OF_BUF;
                break;
            }
            break;
        case '\0':
            ox_sax_drive_error(dr, NO_TERM "not terminated");
            goto END_OF_BUF;
            break;
        default: break;
        }
    }
END_OF_BUF:
    if ('\0' != c) {
        *(dr->buf.tail - 1) = '\0';
    }
    if (0 != parent) {
        parent->childCnt++;
    }
    // TBD check parent overlay
    if (dr->has_text && !dr->blocked) {
        args[0] = rb_str_new2(dr->buf.str);
        if (0 != dr->encoding) {
            rb_enc_associate(args[0], dr->encoding);
        }
        dr->set_pos(dr->handler, pos);
        dr->set_line(dr->handler, line);
        dr->set_col(dr->handler, col);
        rb_funcall2(dr->handler, ox_text_id, 1, args);
    }
    dr->buf.str = 0;
    if ('\0' != c) {
        *(dr->buf.tail - 1) = '<';
    }
    return c;
}

static char read_attrs(SaxDrive dr, char c, char termc, char term2, int is_xml, int eq_req, Hint h) {
    VALUE name        = Qnil;
    int   is_encoding = 0;
    off_t pos;
    off_t line;
    off_t col;
    char *attr_value;

    // already protected by caller
    dr->buf.str = dr->buf.tail;
    if (is_white(c)) {
        c = buf_next_non_white(&dr->buf);
    }
    while (termc != c && term2 != c) {
        buf_backup(&dr->buf);
        if ('\0' == c) {
            ox_sax_drive_error(dr, NO_TERM "attributes not terminated");
            return '\0';
        }
        pos  = dr->buf.pos + 1;
        line = dr->buf.line;
        col  = dr->buf.col + 1;
        if ('\0' == (c = read_name_token(dr))) {
            ox_sax_drive_error(dr, NO_TERM "error reading token");
            return '\0';
        }
        if (is_xml && 0 == strcasecmp("encoding", dr->buf.str)) {
            is_encoding = 1;
        }
        if (dr->want_attr_name) {
            name = str2sym(dr, dr->buf.str, dr->buf.tail - dr->buf.str - 1, 0);
        }
        if (is_white(c)) {
            c = buf_next_non_white(&dr->buf);
        }
        if ('=' != c) {
            // TBD allow in smart mode
            if (eq_req) {
                dr->err = 1;
                return c;
            } else {
                ox_sax_drive_error(dr, WRONG_CHAR "no attribute value");
                attr_value = (char *)"";
            }
        } else {
            pos        = dr->buf.pos + 1;
            line       = dr->buf.line;
            col        = dr->buf.col + 1;
            c          = read_quoted_value(dr, '?' == termc);
            attr_value = dr->buf.str;

            if (is_encoding) {
                dr->encoding = rb_enc_find(dr->buf.str);
                is_encoding  = 0;
            }
        }
        if (0 >= dr->blocked && (NULL == h || ActiveOverlay == h->overlay || NestOverlay == h->overlay)) {
            dr->attr_cb(dr, name, attr_value, pos, line, col);
        }
        if (is_white(c)) {
            c = buf_next_non_white(&dr->buf);
        }
    }
    dr->buf.str = 0;

    return c;
}

/* The character after the word is returned. dr->buf.tail is one past
 * that. dr->buf.str will point to the token which will be '\0' terminated.
 */
static char read_name_token(SaxDrive dr) {
    char c;

    dr->buf.str = dr->buf.tail;
    c           = buf_get(&dr->buf);
    if (is_white(c)) {
        c           = buf_next_non_white(&dr->buf);
        dr->buf.str = dr->buf.tail - 1;
    }
    while (1) {
        switch (c) {
        case ' ':
        case '\t':
        case '\f':
        case '?':
        case '=':
        case '/':
        case '>':
        case '<':
        case '\n':
        case '\r': *(dr->buf.tail - 1) = '\0'; return c;
        case '\0':
            /* documents never terminate after a name token */
            ox_sax_drive_error(dr, NO_TERM "document not terminated");
            return '\0';
        case ':':
            if ('\0' == *dr->options.strip_ns) {
                break;
            } else if ('*' == *dr->options.strip_ns && '\0' == dr->options.strip_ns[1]) {
                dr->buf.str = dr->buf.tail;
            } else if (dr->options.smart &&
                       0 == strncasecmp(dr->options.strip_ns, dr->buf.str, dr->buf.tail - dr->buf.str - 1)) {
                dr->buf.str = dr->buf.tail;
            } else if (0 == strncmp(dr->options.strip_ns, dr->buf.str, dr->buf.tail - dr->buf.str - 1)) {
                dr->buf.str = dr->buf.tail;
            }
            break;
        default: break;
        }
        c = buf_get(&dr->buf);
    }
    return '\0';
}

/* The character after the quote or if there is no quote, the character after
 * the word is returned. dr->buf.tail is one past that. dr->buf.str will point
 * to the token which will be '\0' terminated.
 */
static char read_quoted_value(SaxDrive dr, bool inst) {
    char c;

    c = buf_get(&dr->buf);
    if (is_white(c)) {
        c = buf_next_non_white(&dr->buf);
    }
    if ('"' == c || '\'' == c) {
        char term = c;

        dr->buf.str = dr->buf.tail;
        while (term != (c = buf_get(&dr->buf))) {
            if ('\0' == c) {
                ox_sax_drive_error(dr, NO_TERM "quoted value not terminated");
                return '\0';
            }
        }
        // dr->buf.tail is one past quote char
        *(dr->buf.tail - 1) = '\0'; /* terminate value */
        c                   = buf_get(&dr->buf);
        return c;
    }
    // not quoted, look for something that terminates the string
    dr->buf.str = dr->buf.tail - 1;
    // TBD if smart or html then no error
    if (!(dr->options.smart && ox_hints_html() != dr->options.hints)) {
        ox_sax_drive_error(dr, WRONG_CHAR "attribute value not in quotes");
    }
    while ('\0' != (c = buf_get(&dr->buf))) {
        switch (c) {
        case ' ':
            // case '/':
        case '>':
        case '\t':
        case '\n':
        case '\r':
            *(dr->buf.tail - 1) = '\0'; /* terminate value */
            // dr->buf.tail is in the correct position, one after the word terminator
            return c;
        case '?':
            if (inst) {
                *(dr->buf.tail - 1) = '\0'; /* terminate value */
                return c;
            }
            break;
        default: break;
        }
    }
    return '\0';  // should never get here
}

static char *read_hex_uint64(char *b, uint64_t *up) {
    uint64_t u = 0;
    char     c;

    for (; ';' != *b; b++) {
        c = *b;
        if ('0' <= c && c <= '9') {
            u = (u << 4) | (uint64_t)(c - '0');
        } else if ('a' <= c && c <= 'f') {
            u = (u << 4) | (uint64_t)(c - 'a' + 10);
        } else if ('A' <= c && c <= 'F') {
            u = (u << 4) | (uint64_t)(c - 'A' + 10);
        } else {
            return 0;
        }
    }
    *up = u;

    return b;
}

static char *read_10_uint64(char *b, uint64_t *up) {
    uint64_t u = 0;
    char     c;

    for (; ';' != *b; b++) {
        c = *b;
        if ('0' <= c && c <= '9') {
            u = (u * 10) + (uint64_t)(c - '0');
        } else {
            return 0;
        }
    }
    *up = u;

    return b;
}

int ox_sax_collapse_special(SaxDrive dr, char *str, long pos, long line, long col) {
    char *s = str;
    char *b = str;

    while ('\0' != *s) {
        switch (*s) {
        case '&': {
            int   c = 0;
            char *end;

            s++;
            if ('#' == *s) {
                uint64_t u = 0;
                char     x;

                s++;
                if ('x' == *s || 'X' == *s) {
                    x = *s;
                    s++;
                    end = read_hex_uint64(s, &u);
                } else {
                    x   = '\0';
                    end = read_10_uint64(s, &u);
                }
                if (0 == end) {
                    ox_sax_drive_error(dr, NO_TERM "special character does not end with a semicolon");
                    *b++ = '&';
                    *b++ = '#';
                    if ('\0' != x) {
                        *b++ = x;
                    }
                    continue;
                }
                if (u <= 0x000000000000007FULL) {
                    *b++ = (char)u;
                } else if (ox_utf8_encoding == dr->encoding) {
                    b = ox_ucs_to_utf8_chars(b, u);
                } else if (0 == dr->encoding) {
                    dr->encoding = ox_utf8_encoding;
                    b            = ox_ucs_to_utf8_chars(b, u);
                } else {
                    b = ox_ucs_to_utf8_chars(b, u);
                    /*
                    ox_sax_drive_error(dr, NO_TERM "Invalid encoding, need UTF-8 encoding to parse &#nnnn; character
                    sequences."); *b++ = '&'; *b++ = '#'; if ('\0' != x) { *b++ = x;
                    }
                    continue;
                    */
                }
                s = end + 1;
                continue;
            } else if (0 == strncasecmp(s, "lt;", 3)) {
                c = '<';
                s += 3;
                col += 3;
            } else if (0 == strncasecmp(s, "gt;", 3)) {
                c = '>';
                s += 3;
                col += 3;
            } else if (0 == strncasecmp(s, "amp;", 4)) {
                c = '&';
                s += 4;
                col += 4;
            } else if (0 == strncasecmp(s, "quot;", 5)) {
                c = '"';
                s += 5;
                col += 5;
            } else if (0 == strncasecmp(s, "apos;", 5)) {
                c = '\'';
                s += 5;
            } else {
                char  key[16];
                char *k    = key;
                char *kend = key + sizeof(key) - 1;
                char *bn;
                char *s2 = s;

                for (; ';' != *s2 && '\0' != *s2; s2++, k++) {
                    if (kend <= k) {
                        k = key;
                        break;
                    }
                    *k = *s2;
                }
                *k = '\0';
                if ('\0' == *key || NULL == (bn = ox_entity_lookup(b, key))) {
                    ox_sax_drive_error_at(dr, INVALID_FORMAT "Invalid special character sequence", pos, line, col);
                    c = '&';
                } else {
                    b = bn;
                    s = s2 + 1;
                    continue;
                }
            }
            *b++ = (char)c;
            col++;
            break;
        }
        case '\r':
            s++;
            if ('\n' == *s) {
                continue;
            }
            line++;
            col  = 1;
            *b++ = '\n';
            break;
        case '\n':
            line++;
            col = 0;
            // fall through
        default:
            col++;
            *b++ = *s++;
            break;
        }
    }
    *b = '\0';

    return 0;
}

static void hint_clear_empty(SaxDrive dr) {
    Nv nv;

    for (nv = stack_peek(&dr->stack); 0 != nv; nv = stack_peek(&dr->stack)) {
        if (0 == nv->hint) {
            break;
        }
        if (nv->hint->empty) {
            end_element_cb(dr, nv->val, dr->buf.pos, dr->buf.line, dr->buf.col, nv->hint);
            stack_pop(&dr->stack);
        } else {
            break;
        }
    }
}

static Nv hint_try_close(SaxDrive dr, const char *name) {
    Hint h = ox_hint_find(dr->options.hints, name);
    Nv   nv;

    if (0 == h) {
        return 0;
    }
    for (nv = stack_peek(&dr->stack); 0 != nv; nv = stack_peek(&dr->stack)) {
        if (nv_same_name(nv, name, true)) {
            stack_pop(&dr->stack);
            return nv;
        }
        if (0 == nv->hint) {
            break;
        }
        if (nv->hint->empty) {
            end_element_cb(dr, nv->val, dr->buf.pos, dr->buf.line, dr->buf.col, nv->hint);
            dr->stack.tail = nv;
        } else {
            break;
        }
    }
    return 0;
}
