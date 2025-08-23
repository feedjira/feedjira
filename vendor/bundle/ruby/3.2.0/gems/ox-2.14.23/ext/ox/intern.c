// Copyright (c) 2011, 2021 Peter Ohler. All rights reserved.
// Licensed under the MIT License. See LICENSE file in the project root for license details.

#include "intern.h"

#include <stdint.h>

#include "cache.h"
#include "ox.h"
#include "ruby/version.h"

// These are statics but in an attempt to stop the cross linking or maybe
// something in Ruby they all have been given an ox prefix.
static struct _cache *ox_str_cache = NULL;
static VALUE          ox_str_cache_obj;

static struct _cache *ox_sym_cache = NULL;
static VALUE          ox_sym_cache_obj;

static struct _cache *ox_attr_cache = NULL;
static VALUE          ox_attr_cache_obj;

static struct _cache *ox_id_cache = NULL;
static VALUE          ox_id_cache_obj;

static VALUE form_str(const char *str, size_t len) {
    return rb_str_freeze(rb_utf8_str_new(str, len));
}

static VALUE form_sym(const char *str, size_t len) {
    return rb_to_symbol(rb_str_freeze(rb_utf8_str_new(str, len)));
}

static VALUE form_attr(const char *str, size_t len) {
    char buf[256];

    if (sizeof(buf) - 2 <= len) {
        char *b = ALLOC_N(char, len + 2);
        ID    id;

        if ('~' == *str) {
            memcpy(b, str + 1, len - 1);
            b[len - 1] = '\0';
            len -= 2;
        } else {
            *b = '@';
            memcpy(b + 1, str, len);
            b[len + 1] = '\0';
        }
        id = rb_intern3(buf, len + 1, rb_utf8_encoding());
        xfree(b);
        return id;
    }
    if ('~' == *str) {
        memcpy(buf, str + 1, len - 1);
        buf[len - 1] = '\0';
        len -= 2;
    } else {
        *buf = '@';
        memcpy(buf + 1, str, len);
        buf[len + 1] = '\0';
    }
    return (VALUE)rb_intern3(buf, len + 1, rb_utf8_encoding());
}

static VALUE form_id(const char *str, size_t len) {
    return (VALUE)rb_intern3(str, len, rb_utf8_encoding());
}

void ox_hash_init(void) {
    VALUE cache_class = rb_define_class_under(Ox, "Cache", rb_cObject);
#if RUBY_API_VERSION_CODE >= 30200
    rb_undef_alloc_func(cache_class);
#endif

    ox_str_cache     = ox_cache_create(0, form_str, true, false);
    ox_str_cache_obj = TypedData_Wrap_Struct(cache_class, &ox_cache_type, ox_str_cache);
    rb_gc_register_address(&ox_str_cache_obj);

    ox_sym_cache     = ox_cache_create(0, form_sym, true, false);
    ox_sym_cache_obj = TypedData_Wrap_Struct(cache_class, &ox_cache_type, ox_sym_cache);
    rb_gc_register_address(&ox_sym_cache_obj);

    ox_attr_cache     = ox_cache_create(0, form_attr, false, false);
    ox_attr_cache_obj = TypedData_Wrap_Struct(cache_class, &ox_cache_type, ox_attr_cache);
    rb_gc_register_address(&ox_attr_cache_obj);

    ox_id_cache     = ox_cache_create(0, form_id, false, false);
    ox_id_cache_obj = TypedData_Wrap_Struct(cache_class, &ox_cache_type, ox_id_cache);
    rb_gc_register_address(&ox_id_cache_obj);
}

VALUE
ox_str_intern(const char *key, size_t len, const char **keyp) {
    // For huge cache sizes over half a million the rb_enc_interned_str
    // performs slightly better but at more "normal" size of a several
    // thousands the cache intern performs about 20% better.
#if HAVE_RB_ENC_INTERNED_STR && 0
    return rb_enc_interned_str(key, len, rb_utf8_encoding());
#else
    return ox_cache_intern(ox_str_cache, key, len, keyp);
#endif
}

VALUE
ox_sym_intern(const char *key, size_t len, const char **keyp) {
    return ox_cache_intern(ox_sym_cache, key, len, keyp);
}

ID ox_attr_intern(const char *key, size_t len) {
    return ox_cache_intern(ox_attr_cache, key, len, NULL);
}

ID ox_id_intern(const char *key, size_t len) {
    return ox_cache_intern(ox_id_cache, key, len, NULL);
}

char *ox_strndup(const char *s, size_t len) {
    char *d = ALLOC_N(char, len + 1);

    memcpy(d, s, len);
    d[len] = '\0';

    return d;
}

VALUE
ox_utf8_name(const char *str, size_t len, rb_encoding *encoding, const char **strp) {
    return ox_str_intern(str, len, strp);
}

VALUE
ox_utf8_sym(const char *str, size_t len, rb_encoding *encoding, const char **strp) {
    return ox_sym_intern(str, len, strp);
}

VALUE
ox_enc_sym(const char *str, size_t len, rb_encoding *encoding, const char **strp) {
    VALUE sym = rb_str_new2(str);

    rb_enc_associate(sym, encoding);
    if (NULL != strp) {
        *strp = StringValuePtr(sym);
    }
    return rb_to_symbol(sym);
}

VALUE
ox_enc_name(const char *str, size_t len, rb_encoding *encoding, const char **strp) {
    VALUE sym = rb_str_new2(str);

    rb_enc_associate(sym, encoding);
    if (NULL != strp) {
        *strp = StringValuePtr(sym);
    }
    return sym;
}
