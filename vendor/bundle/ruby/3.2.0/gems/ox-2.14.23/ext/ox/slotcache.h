/* slotcache.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef SLOT_CACHE_H
#define SLOT_CACHE_H

#include "ruby.h"

typedef struct _slotCache *SlotCache;

extern void slot_cache_new(SlotCache *cache);

extern VALUE slot_cache_get(SlotCache cache, const char *key, VALUE **slot, const char **keyp);

extern void slot_cache_print(SlotCache cache);

#endif /* SLOT_CACHE_H */
