/* hint.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef OX_HINT_H
#define OX_HINT_H

#include <stdbool.h>

typedef enum {
    ActiveOverlay   = 0,
    InactiveOverlay = 'i',
    BlockOverlay    = 'b',
    OffOverlay      = 'o',
    AbortOverlay    = 'a',
    NestOverlay     = 'n',  // nest flag is ignored
} Overlay;

typedef struct _hint {
    const char  *name;
    char         empty;    // must be closed or close auto it, not error
    char         nest;     // nesting allowed
    char         jump;     // jump to end <script> ... </script>
    char         overlay;  // Overlay
    const char **parents;
} *Hint;

typedef struct _hints {
    const char *name;
    Hint        hints;  // array of hints
    int         size;
} *Hints;

extern Hints ox_hints_html(void);
extern Hint  ox_hint_find(Hints hints, const char *name);
extern Hints ox_hints_dup(Hints h);
extern void  ox_hints_destroy(Hints h);

#endif /* OX_HINT_H */
