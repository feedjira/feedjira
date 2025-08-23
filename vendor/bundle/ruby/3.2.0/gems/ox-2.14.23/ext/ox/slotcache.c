/* slotcache.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include "slotcache.h"

#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

struct _slotCache {
    /* The key is a length byte followed by the key as a string. If the key is longer than 254 characters then the
       length is 255. The key can be for a premature value and in that case the length byte is greater than the length
       of the key. */
    char              *key;
    VALUE              value;
    struct _slotCache *slots[16];
};

static void slot_print(SlotCache cache, unsigned int depth);

static char *form_key(const char *s) {
    size_t len = strlen(s);
    char  *d   = ALLOC_N(char, len + 2);

    *(uint8_t *)d = (255 <= len) ? 255 : len;
    memcpy(d + 1, s, len + 1);

    return d;
}

void slot_cache_new(SlotCache *cache) {
    *cache          = ALLOC(struct _slotCache);
    (*cache)->key   = 0;
    (*cache)->value = Qundef;
    memset((*cache)->slots, 0, sizeof((*cache)->slots));
}

VALUE
slot_cache_get(SlotCache cache, const char *key, VALUE **slot, const char **keyp) {
    unsigned char *k = (unsigned char *)key;
    SlotCache     *cp;

    for (; '\0' != *k; k++) {
        cp = cache->slots + (unsigned int)(*k >> 4); /* upper 4 bits */
        if (0 == *cp) {
            slot_cache_new(cp);
        }
        cache = *cp;
        cp    = cache->slots + (unsigned int)(*k & 0x0F); /* lower 4 bits */
        if (0 == *cp) { /* nothing on this tree so set key and value as a premature key/value pair */
            slot_cache_new(cp);
            cache      = *cp;
            cache->key = form_key(key);
            break;
        } else {
            int depth = (int)(k - (unsigned char *)key + 1);

            cache = *cp;

            if ('\0' == *(k + 1)) {    /* exact match */
                if (0 == cache->key) { /* nothing in this spot so take it */
                    cache->key = form_key(key);
                    break;
                } else if ((depth == *cache->key || 255 < depth) && 0 == strcmp(key, cache->key + 1)) { /* match */
                    break;
                } else { /* have to move the current premature key/value deeper */
                    unsigned char *ck   = (unsigned char *)(cache->key + depth + 1);
                    SlotCache      orig = *cp;

                    cp = (*cp)->slots + (*ck >> 4);
                    slot_cache_new(cp);
                    cp = (*cp)->slots + (*ck & 0x0F);
                    slot_cache_new(cp);
                    (*cp)->key   = cache->key;
                    (*cp)->value = cache->value;
                    orig->key    = form_key(key);
                    orig->value  = Qundef;
                }
            } else {                   /* not exact match but on the path */
                if (0 != cache->key) { /* there is a key/value here already */
                    if (depth == *cache->key || (255 <= depth && 0 == strncmp(cache->key, key, depth) &&
                                                 '\0' == cache->key[depth])) { /* key belongs here */
                        continue;
                    } else {
                        unsigned char *ck   = (unsigned char *)(cache->key + depth + 1);
                        SlotCache      orig = *cp;

                        cp = (*cp)->slots + (*ck >> 4);
                        slot_cache_new(cp);
                        cp = (*cp)->slots + (*ck & 0x0F);
                        slot_cache_new(cp);
                        (*cp)->key   = cache->key;
                        (*cp)->value = cache->value;
                        orig->key    = 0;
                        orig->value  = Qundef;
                    }
                }
            }
        }
    }
    *slot = &cache->value;
    if (0 != keyp) {
        if (0 == cache->key) {
            printf("*** Error: failed to set the key for '%s'\n", key);
            *keyp = 0;
        } else {
            *keyp = cache->key + 1;
        }
    }
    return cache->value;
}

void slot_cache_print(SlotCache cache) {
    /*printf("-------------------------------------------\n");*/
    slot_print(cache, 0);
}

static void slot_print(SlotCache c, unsigned int depth) {
    char         indent[256];
    SlotCache   *cp;
    unsigned int i;

    if (sizeof(indent) - 1 < depth) {
        depth = ((int)sizeof(indent) - 1);
    }
    memset(indent, ' ', depth);
    indent[depth] = '\0';
    for (i = 0, cp = c->slots; i < 16; i++, cp++) {
        if (0 == *cp) {
            /*printf("%s%02u:\n", indent, i);*/
        } else {
            if (0 == (*cp)->key && Qundef == (*cp)->value) {
                printf("%s%02u:\n", indent, i);
            } else {
                const char *vs;
                const char *clas;

                if (Qundef == (*cp)->value) {
                    vs   = "undefined";
                    clas = "";
                } else {
                    VALUE rs = rb_String((*cp)->value);

                    vs   = StringValuePtr(rs);
                    clas = rb_class2name(rb_obj_class((*cp)->value));
                }
                printf("%s%02u: %s = %s (%s)\n", indent, i, (*cp)->key, vs, clas);
            }
            slot_print(*cp, depth + 2);
        }
    }
}
