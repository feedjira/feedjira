/* special.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef OX_SPECIAL_H
#define OX_SPECIAL_H

#include <stdint.h>

extern char *ox_ucs_to_utf8_chars(char *text, uint64_t u);
extern char *ox_entity_lookup(char *text, const char *key);

#endif /* OX_SPECIAL_H */
