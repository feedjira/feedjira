/* hash_load.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <errno.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ox.h"
#include "ruby.h"

#define MARK_INC 256

// The approach taken for the hash and has_no_attrs parsing is to push just
// the key on to the stack and then decide what to do on the way up/out.

static VALUE create_top(PInfo pi) {
    volatile VALUE top = rb_hash_new();

    helper_stack_push(&pi->helpers, 0, top, HashCode);
    pi->obj = top;

    return top;
}

static void mark_value(PInfo pi, VALUE val) {
    if (NULL == pi->marked) {
        pi->marked    = ALLOC_N(VALUE, MARK_INC);
        pi->mark_size = MARK_INC;
    } else if (pi->mark_size <= pi->mark_cnt) {
        pi->mark_size += MARK_INC;
        REALLOC_N(pi->marked, VALUE, pi->mark_size);
    }
    pi->marked[pi->mark_cnt] = val;
    pi->mark_cnt++;
}

static bool marked(PInfo pi, VALUE val) {
    if (NULL != pi->marked) {
        VALUE *vp = pi->marked + pi->mark_cnt - 1;

        for (; pi->marked <= vp; vp--) {
            if (val == *vp) {
                return true;
            }
        }
    }
    return false;
}

static void unmark(PInfo pi, VALUE val) {
    if (NULL != pi->marked) {
        VALUE *vp = pi->marked + pi->mark_cnt - 1;
        int    i;

        for (i = 0; pi->marked <= vp; vp--, i++) {
            if (val == *vp) {
                for (; 0 < i; i--, vp++) {
                    *vp = *(vp + 1);
                }
                pi->mark_cnt--;
                break;
            }
        }
    }
}

static void add_str(PInfo pi, VALUE s) {
    Helper         parent = helper_stack_peek(&pi->helpers);
    volatile VALUE a;

    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
    switch (parent->type) {
    case NoCode:
        parent->obj  = s;
        parent->type = StringCode;
        break;
    case ArrayCode: rb_ary_push(parent->obj, s); break;
    default:
        a = rb_ary_new();
        rb_ary_push(a, parent->obj);
        rb_ary_push(a, s);
        parent->obj  = a;
        parent->type = ArrayCode;
        break;
    }
}

static void add_text(PInfo pi, char *text, int closed) {
    VALUE s = rb_str_new2(text);
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
    add_str(pi, s);
}

static void add_cdata(PInfo pi, const char *text, size_t len) {
    VALUE s = rb_str_new2(text);
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
    add_str(pi, s);
}

static void add_element(PInfo pi, const char *ename, Attr attrs, int hasChildren) {
    VALUE s = rb_str_new2(ename);
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
    if (helper_stack_empty(&pi->helpers)) {
        create_top(pi);
    }
    if (NULL != attrs && NULL != attrs->name) {
        volatile VALUE h = rb_hash_new();
        volatile VALUE key;
        volatile VALUE val;
        volatile VALUE a;

        for (; 0 != attrs->name; attrs++) {
            key = rb_str_new2(attrs->name);
            if (0 != pi->options->rb_enc) {
                rb_enc_associate(key, pi->options->rb_enc);
            }
            if (Qnil != pi->options->attr_key_mod) {
                key = rb_funcall(pi->options->attr_key_mod, ox_call_id, 1, key);
            } else if (Yes == pi->options->sym_keys) {
                key = rb_id2sym(rb_intern_str(key));
            }
            val = rb_str_new2(attrs->value);
            if (0 != pi->options->rb_enc) {
                rb_enc_associate(val, pi->options->rb_enc);
            }
            rb_hash_aset(h, key, val);
        }
        a = rb_ary_new();
        rb_ary_push(a, h);
        mark_value(pi, a);
        helper_stack_push(&pi->helpers, rb_intern_str(s), a, ArrayCode);
    } else {
        helper_stack_push(&pi->helpers, rb_intern_str(s), Qnil, NoCode);
    }
}

static void add_element_no_attrs(PInfo pi, const char *ename, Attr attrs, int hasChildren) {
    VALUE s = rb_str_new2(ename);
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
    if (helper_stack_empty(&pi->helpers)) {
        create_top(pi);
    }
    helper_stack_push(&pi->helpers, rb_intern_str(s), Qnil, NoCode);
}

static int umark_hash_cb(VALUE key, VALUE value, VALUE x) {
    unmark((PInfo)x, value);

    return ST_CONTINUE;
}

static void end_element_core(PInfo pi, const char *ename, bool check_marked) {
    Helper         e      = helper_stack_pop(&pi->helpers);
    Helper         parent = helper_stack_peek(&pi->helpers);
    volatile VALUE pobj   = parent->obj;
    volatile VALUE found  = Qundef;
    volatile VALUE key;
    volatile VALUE a;

    if (NoCode == e->type) {
        e->obj = Qnil;
    }
    if (Qnil != pi->options->element_key_mod) {
        key = rb_funcall(pi->options->element_key_mod, ox_call_id, 1, rb_id2str(e->var));
    } else if (Yes == pi->options->sym_keys) {
        key = rb_id2sym(e->var);
    } else {
        key = rb_id2str(e->var);
    }
    // Make sure the parent is a Hash. If not set then make a Hash. If an
    // Array or non-Hash then append to array or create and append.
    switch (parent->type) {
    case NoCode:
        pobj         = rb_hash_new();
        parent->obj  = pobj;
        parent->type = HashCode;
        break;
    case ArrayCode:
        pobj = rb_hash_new();
        rb_ary_push(parent->obj, pobj);
        break;
    case HashCode: found = rb_hash_lookup2(parent->obj, key, Qundef); break;
    default:
        a = rb_ary_new();
        rb_ary_push(a, parent->obj);
        pobj = rb_hash_new();
        rb_ary_push(a, pobj);
        parent->obj  = a;
        parent->type = ArrayCode;
        break;
    }
    if (Qundef == found) {
        rb_hash_aset(pobj, key, e->obj);
    } else if (RUBY_T_ARRAY == rb_type(found)) {
        if (check_marked && marked(pi, found)) {
            unmark(pi, found);
            a = rb_ary_new();
            rb_ary_push(a, found);
            rb_ary_push(a, e->obj);
            rb_hash_aset(pobj, key, a);
        } else {
            rb_ary_push(found, e->obj);
        }
    } else {  // something there other than an array
        if (check_marked && marked(pi, e->obj)) {
            unmark(pi, e->obj);
        }
        a = rb_ary_new();
        rb_ary_push(a, found);
        rb_ary_push(a, e->obj);
        rb_hash_aset(pobj, key, a);
    }
    if (check_marked && NULL != pi->marked && RUBY_T_HASH == rb_type(e->obj)) {
        rb_hash_foreach(e->obj, umark_hash_cb, (VALUE)pi);
    }
}

static void end_element(PInfo pi, const char *ename) {
    end_element_core(pi, ename, true);
}

static void end_element_no_attrs(PInfo pi, const char *ename) {
    end_element_core(pi, ename, false);
}

static void finish(PInfo pi) {
    xfree(pi->marked);
}

static void set_encoding_from_instruct(PInfo pi, Attr attrs) {
    for (; 0 != attrs->name; attrs++) {
        if (0 == strcmp("encoding", attrs->name)) {
            pi->options->rb_enc = rb_enc_find(attrs->value);
        }
    }
}

static void instruct(PInfo pi, const char *target, Attr attrs, const char *content) {
    if (0 == strcmp("xml", target)) {
        set_encoding_from_instruct(pi, attrs);
    }
}

struct _parseCallbacks _ox_hash_callbacks = {
    instruct,
    NULL,
    NULL,
    NULL,
    add_text,
    add_element,
    end_element,
    finish,
};

ParseCallbacks ox_hash_callbacks = &_ox_hash_callbacks;

struct _parseCallbacks _ox_hash_cdata_callbacks = {
    instruct,
    NULL,
    NULL,
    add_cdata,
    add_text,
    add_element,
    end_element,
    finish,
};

ParseCallbacks ox_hash_cdata_callbacks = &_ox_hash_cdata_callbacks;

struct _parseCallbacks _ox_hash_no_attrs_callbacks = {
    instruct,
    NULL,
    NULL,
    NULL,
    add_text,
    add_element_no_attrs,
    end_element_no_attrs,
    NULL,
};

ParseCallbacks ox_hash_no_attrs_callbacks = &_ox_hash_no_attrs_callbacks;

struct _parseCallbacks _ox_hash_no_attrs_cdata_callbacks = {
    instruct,
    NULL,
    NULL,
    add_cdata,
    add_text,
    add_element_no_attrs,
    end_element_no_attrs,
    NULL,
};

ParseCallbacks ox_hash_no_attrs_cdata_callbacks = &_ox_hash_no_attrs_cdata_callbacks;
