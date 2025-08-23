/* sax_as.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

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

#include "ox.h"
#include "ruby.h"
#include "ruby/version.h"
#include "sax.h"

static VALUE parse_double_time(const char *text) {
    long        v   = 0;
    long        v2  = 0;
    const char *dot = 0;
    char        c;

    for (; '.' != *text; text++) {
        c = *text;
        if (c < '0' || '9' < c) {
            return Qnil;
        }
        v = 10 * v + (long)(c - '0');
    }
    dot = text++;
    for (; '\0' != *text && text - dot <= 6; text++) {
        c = *text;
        if (c < '0' || '9' < c) {
            return Qnil;
        }
        v2 = 10 * v2 + (long)(c - '0');
    }
    for (; text - dot <= 9; text++) {
        v2 *= 10;
    }
    return rb_time_nano_new(v, v2);
}

typedef struct _tp {
    int  cnt;
    char end;
    char alt;
} *Tp;

static VALUE parse_xsd_time(const char *text) {
    long       cargs[10];
    long      *cp = cargs;
    long       v;
    int        i;
    char       c       = '\0';
    struct _tp tpa[10] = {{4, '-', '-'},
                          {2, '-', '-'},
                          {2, 'T', ' '},
                          {2, ':', ':'},
                          {2, ':', ':'},
                          {2, '.', '.'},
                          {9, '+', '-'},
                          {2, ':', ':'},
                          {2, '\0', '\0'},
                          {0, '\0', '\0'}};
    Tp         tp      = tpa;
    struct tm  tm;

    memset(cargs, 0, sizeof(cargs));
    for (; 0 != tp->cnt; tp++) {
        for (i = tp->cnt, v = 0; 0 < i; text++, i--) {
            c = *text;
            if (c < '0' || '9' < c) {
                if ('\0' == c || tp->end == c || tp->alt == c) {
                    break;
                }
                return Qnil;
            }
            v = 10 * v + (long)(c - '0');
        }
        if ('\0' == c) {
            break;
        }
        c = *text++;
        if (tp->end != c && tp->alt != c) {
            return Qnil;
        }
        *cp++ = v;
    }
    tm.tm_year = (int)cargs[0] - 1900;
    tm.tm_mon  = (int)cargs[1] - 1;
    tm.tm_mday = (int)cargs[2];
    tm.tm_hour = (int)cargs[3];
    tm.tm_min  = (int)cargs[4];
    tm.tm_sec  = (int)cargs[5];
    return rb_time_nano_new(mktime(&tm), cargs[6]);
}

/* call-seq: as_s()
 *
 * *return* value as an String.
 */
static VALUE sax_value_as_s(VALUE self) {
    SaxDrive dr;
    VALUE    rs;

    TypedData_Get_Struct(self, struct _saxDrive, &ox_sax_value_type, dr);

    if ('\0' == *dr->buf.str) {
        return Qnil;
    }
    if (dr->options.convert_special) {
        ox_sax_collapse_special(dr, dr->buf.str, dr->buf.pos, dr->buf.line, dr->buf.col);
    }
    switch (dr->options.skip) {
    case CrSkip: buf_collapse_return(dr->buf.str); break;
    case SpcSkip: buf_collapse_white(dr->buf.str); break;
    default: break;
    }
    rs = rb_str_new2(dr->buf.str);
    if (0 != dr->encoding) {
        rb_enc_associate(rs, dr->encoding);
    }
    return rs;
}

/* call-seq: as_sym()
 *
 * *return* value as an Symbol.
 */
static VALUE sax_value_as_sym(VALUE self) {
    SaxDrive dr;

    TypedData_Get_Struct(self, struct _saxDrive, &ox_sax_value_type, dr);

    if ('\0' == *dr->buf.str) {
        return Qnil;
    }
    return str2sym(dr, dr->buf.str, strlen(dr->buf.str), 0);
}

/* call-seq: as_f()
 *
 * *return* value as an Float.
 */
static VALUE sax_value_as_f(VALUE self) {
    SaxDrive dr;

    TypedData_Get_Struct(self, struct _saxDrive, &ox_sax_value_type, dr);

    if ('\0' == *dr->buf.str) {
        return Qnil;
    }
    return rb_float_new(strtod(dr->buf.str, 0));
}

/* call-seq: as_i()
 *
 * *return* value as an Fixnum.
 */
static VALUE sax_value_as_i(VALUE self) {
    SaxDrive    dr;
    const char *s;
    long        n   = 0;
    int         neg = 0;

    TypedData_Get_Struct(self, struct _saxDrive, &ox_sax_value_type, dr);
    s = dr->buf.str;

    if ('\0' == *s) {
        return Qnil;
    }
    if ('-' == *s) {
        neg = 1;
        s++;
    } else if ('+' == *s) {
        s++;
    }
    for (; '\0' != *s; s++) {
        if ('0' <= *s && *s <= '9') {
            n = n * 10 + (*s - '0');
        } else {
            rb_raise(ox_arg_error_class, "Not a valid Fixnum.\n");
        }
    }
    if (neg) {
        n = -n;
    }
    return LONG2NUM(n);
}

/* call-seq: as_time()
 *
 * *return* value as an Time.
 */
static VALUE sax_value_as_time(VALUE self) {
    SaxDrive    dr;
    const char *str;
    VALUE       t;

    TypedData_Get_Struct(self, struct _saxDrive, &ox_sax_value_type, dr);
    str = dr->buf.str;

    if ('\0' == *str) {
        return Qnil;
    }
    if (Qnil == (t = parse_double_time(str)) && Qnil == (t = parse_xsd_time(str))) {
        VALUE args[1];

        /*printf("**** time parse\n"); */
        *args = rb_str_new2(str);
        t     = rb_funcall2(ox_time_class, ox_parse_id, 1, args);
    }
    return t;
}

/* call-seq: as_bool()
 *
 * *return* value as an boolean.
 */
static VALUE sax_value_as_bool(VALUE self) {
    SaxDrive dr;

    TypedData_Get_Struct(self, struct _saxDrive, &ox_sax_value_type, dr);
    return (0 == strcasecmp("true", dr->buf.str)) ? Qtrue : Qfalse;
}

/* call-seq: empty()
 *
 * *return* true if the value is empty.
 */
static VALUE sax_value_empty(VALUE self) {
    SaxDrive dr;

    TypedData_Get_Struct(self, struct _saxDrive, &ox_sax_value_type, dr);
    return ('\0' == *dr->buf.str) ? Qtrue : Qfalse;
}

/* Document-class: Ox::Sax::Value
 *
 * Values in the SAX callbacks. They can be converted to various different
 * types. with the _as_x()_ methods.
 */
void ox_sax_define(void) {
#if 0
    ox = rb_define_module("Ox");
#if RUBY_API_VERSION_CODE >= 30200
    sax_module = rb_define_class_under(ox, "Sax", rb_cObject);
#endif
#endif
    VALUE sax_module = rb_const_get_at(Ox, rb_intern("Sax"));

    ox_sax_value_class = rb_define_class_under(sax_module, "Value", rb_cObject);
#if RUBY_API_VERSION_CODE >= 30200
    rb_undef_alloc_func(ox_sax_value_class);
#endif

    rb_define_method(ox_sax_value_class, "as_s", sax_value_as_s, 0);
    rb_define_method(ox_sax_value_class, "as_sym", sax_value_as_sym, 0);
    rb_define_method(ox_sax_value_class, "as_i", sax_value_as_i, 0);
    rb_define_method(ox_sax_value_class, "as_f", sax_value_as_f, 0);
    rb_define_method(ox_sax_value_class, "as_time", sax_value_as_time, 0);
    rb_define_method(ox_sax_value_class, "as_bool", sax_value_as_bool, 0);
    rb_define_method(ox_sax_value_class, "empty?", sax_value_empty, 0);
}
