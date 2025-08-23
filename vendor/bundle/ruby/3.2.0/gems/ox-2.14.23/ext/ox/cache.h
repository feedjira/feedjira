// Copyright (c) 2021 Peter Ohler. All rights reserved.
// Licensed under the MIT License. See LICENSE file in the project root for license details.

#ifndef OX_CACHE_H
#define OX_CACHE_H

#include <ruby.h>
#include <stdbool.h>

#define CACHE_MAX_KEY 35

struct _cache;

extern const rb_data_type_t ox_cache_type;

extern struct _cache *ox_cache_create(size_t size, VALUE (*form)(const char *str, size_t len), bool mark, bool locking);
extern void           ox_cache_free(void *ptr);
extern void           ox_cache_mark(void *ptr);
extern VALUE          ox_cache_intern(struct _cache *c, const char *key, size_t len, const char **keyp);

#endif /* OX_CACHE_H */
