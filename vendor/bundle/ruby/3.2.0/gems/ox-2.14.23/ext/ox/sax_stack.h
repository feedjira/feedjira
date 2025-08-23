/* sax_stack.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef OX_SAX_STACK_H
#define OX_SAX_STACK_H

#include <stdlib.h>

#include "intern.h"
#include "sax_hint.h"

#define STACK_INC 32
#define NV_BUF_MAX 64

typedef struct _nv {
    char        name_buf[NV_BUF_MAX];
    const char *name;
    VALUE       val;
    int         childCnt;
    Hint        hint;
} *Nv;

typedef struct _nStack {
    struct _nv base[STACK_INC];
    Nv         head; /* current stack */
    Nv         end;  /* stack end */
    Nv         tail; /* pointer to one past last element name on stack */
} *NStack;

inline static void stack_init(NStack stack) {
    stack->head = stack->base;
    stack->end  = stack->base + sizeof(stack->base) / sizeof(struct _nv);
    stack->tail = stack->head;
}

inline static int stack_empty(NStack stack) {
    return (stack->head == stack->tail);
}

inline static void stack_cleanup(NStack stack) {
    if (stack->base != stack->head) {
        xfree(stack->head);
    }
}

inline static void stack_push(NStack stack, const char *name, size_t nlen, VALUE val, Hint hint) {
    if (stack->end <= stack->tail) {
        size_t len  = stack->end - stack->head;
        size_t toff = stack->tail - stack->head;

        if (stack->base == stack->head) {
            stack->head = ALLOC_N(struct _nv, len + STACK_INC);
            memcpy(stack->head, stack->base, sizeof(struct _nv) * len);
        } else {
            REALLOC_N(stack->head, struct _nv, len + STACK_INC);
        }
        stack->tail = stack->head + toff;
        stack->end  = stack->head + len + STACK_INC;
    }
    if (NV_BUF_MAX <= nlen) {
        stack->tail->name = ox_strndup(name, nlen);
    } else {
        strncpy(stack->tail->name_buf, name, nlen);
        stack->tail->name_buf[nlen] = '\0';
        stack->tail->name           = NULL;
    }
    stack->tail->val      = val;
    stack->tail->hint     = hint;
    stack->tail->childCnt = 0;
    stack->tail++;
}

inline static Nv stack_peek(NStack stack) {
    if (stack->head < stack->tail) {
        return stack->tail - 1;
    }
    return NULL;
}

inline static Nv stack_pop(NStack stack) {
    if (stack->head < stack->tail) {
        stack->tail--;
        if (NULL != stack->tail->name) {
            xfree((char *)(stack->tail->name));
        }
        return stack->tail;
    }
    return NULL;
}

inline static const char *nv_name(Nv nv) {
    if (NULL == nv->name) {
        return nv->name_buf;
    }
    return nv->name;
}

inline static int nv_same_name(Nv nv, const char *name, bool smart) {
    if (smart) {
        if (NULL == nv->name) {
            return (0 == strcasecmp(name, nv->name_buf));
        }
        return (0 == strcasecmp(name, nv->name));
    }
    if (NULL == nv->name) {
        return (0 == strcmp(name, nv->name_buf));
    }
    return (0 == strcmp(name, nv->name));
}

#endif /* OX_SAX_STACK_H */
