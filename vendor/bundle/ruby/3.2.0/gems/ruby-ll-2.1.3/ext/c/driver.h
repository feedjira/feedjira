#ifndef LIBLL_DRIVER_H
#define LIBLL_DRIVER_H

#include <ruby.h>
#include "driver_config.h"
#include "macros.h"
#include "kvec.h"

/**
 * Struct containing the internal state of a Driver instance. This struct is
 * sadly required as rb_block_call() doesn't take any extra, custom arguments
 * (other than a single VALUE). This means we have to use
 * Data_Wrap_Struct/Data_Get_Struct instead :<
 */
typedef struct
{
    DriverConfig *config;

    /* Stack for storing the rules/actions/etc to process */
    kvec_t(long) stack;

    /* Stack for action return values */
    kvec_t(VALUE) value_stack;
} DriverState;

extern void Init_ll_driver();

#endif
