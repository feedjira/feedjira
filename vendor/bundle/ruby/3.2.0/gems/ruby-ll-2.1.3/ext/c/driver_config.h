#ifndef LIBLL_DRIVER_CONFIG_H
#define LIBLL_DRIVER_CONFIG_H

#include <ruby.h>
#include "macros.h"
#include "khash.h"

/* khash based map that maps 64bit integers with longs, semicolon not needed */
KHASH_MAP_INIT_INT64(int64_map, long)

/**
 * Struct containing the configuration (as native C data types) of a parser.
 * This includes the rules to process, the actions and their names, etc.
 *
 * This data is copied over to C to remove the need for invoking Ruby
 * methods/functions to access them, this greatly speeds up the parsing process.
 */
typedef struct
{
    /* Hash mapping Symbol pointers with their indexes */
    khash_t(int64_map) *terminals;

    /* Array of arrays, each containing all the rules to process */
    long **rules;

    /* Array containing the length of each row in the `rules` array */
    long *rule_lengths;

    /* Array of arrays used as the parser lookup table */
    long **table;

    /* Array containing action names as Symbols */
    VALUE *action_names;

    /* Array containing the arity for every action */
    long *action_arg_amounts;

    /* The amount of rule rows */
    long rules_count;

    /* The amount of rows in the lookup table */
    long table_count;

    /* The amount of actions */
    long actions_count;

    /* The amount of terminals */
    long terminals_count;
} DriverConfig;

extern void Init_ll_driver_config();

#endif
