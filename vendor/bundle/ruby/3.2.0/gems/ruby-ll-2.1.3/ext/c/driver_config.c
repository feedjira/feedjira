#include "driver_config.h"

/**
 * Releases memory of the DriverConfig struct and its members.
 */
void ll_driver_config_free(DriverConfig *config)
{
    long rindex;

    FOR(rindex, config->rules_count)
    {
        free(config->rules[rindex]);
    }

    FOR(rindex, config->table_count)
    {
        free(config->table[rindex]);
    }

    free(config->rules);
    free(config->rule_lengths);
    free(config->table);
    free(config->action_names);
    free(config->action_arg_amounts);

    kh_destroy(int64_map, config->terminals);

    free(config);
}

/**
 * Allocates a new DriverConfig.
 */
VALUE ll_driver_config_allocate(VALUE klass)
{
    DriverConfig *config = ALLOC(DriverConfig);

    return Data_Wrap_Struct(
        klass,
        NULL,
        ll_driver_config_free,
        config
    );
}

/**
 * Stores the terminals of the parser in the DriverConfig struct.
 *
 * @param self The current DriverConfig instance.
 * @param array The terminals to store in the struct.
 */
VALUE ll_driver_config_set_terminals(VALUE self, VALUE array)
{
    long index;

    int key_ret;
    khint64_t key;
    VALUE token;
    DriverConfig *config;
    long count = RARRAY_LEN(array);

    Data_Get_Struct(self, DriverConfig, config);

    config->terminals = kh_init(int64_map);

    FOR(index, count)
    {
        token = rb_ary_entry(array, index);
        key   = kh_put(int64_map, config->terminals, token, &key_ret);

        kh_value(config->terminals, key) = index;
    }

    return Qnil;
}

/**
 * Stores the rules in the DriverConfig struct.
 *
 * @param self The DriverConfig instance.
 * @param array The rules to store.
 */
VALUE ll_driver_config_set_rules(VALUE self, VALUE array)
{
    long rindex;
    long cindex;
    long col_count;
    DriverConfig *config;
    VALUE row;
    long row_count = RARRAY_LEN(array);

    Data_Get_Struct(self, DriverConfig, config);

    config->rules        = ALLOC_N(long*, row_count);
    config->rule_lengths = ALLOC_N(long, row_count);

    FOR(rindex, row_count)
    {
        row       = rb_ary_entry(array, rindex);
        col_count = RARRAY_LEN(row);

        config->rules[rindex] = ALLOC_N(long, col_count);

        FOR(cindex, col_count)
        {
            config->rules[rindex][cindex] = NUM2INT(rb_ary_entry(row, cindex));
        }

        config->rule_lengths[rindex] = col_count;
    }

    config->rules_count = row_count;

    return Qnil;
}

/**
 * Stores the lookup table in the DriverConfig struct.
 *
 * @param self The DriverConfig instance.
 * @param array The lookup table.
 */
VALUE ll_driver_config_set_table(VALUE self, VALUE array)
{
    long rindex;
    long cindex;
    long col_count;
    VALUE row;
    DriverConfig *config;
    long row_count = RARRAY_LEN(array);

    Data_Get_Struct(self, DriverConfig, config);

    config->table = ALLOC_N(long*, row_count);

    FOR(rindex, row_count)
    {
        row       = rb_ary_entry(array, rindex);
        col_count = RARRAY_LEN(row);

        config->table[rindex] = ALLOC_N(long, col_count);

        FOR(cindex, col_count)
        {
            config->table[rindex][cindex] = NUM2INT(rb_ary_entry(row, cindex));
        }
    }

    config->table_count = row_count;

    return Qnil;
}

/**
 * Stores the callback actions in the DriverConfig struct.
 *
 * @param self The DriverConfig instance.
 * @param array The callback actions and their arities.
 */
VALUE ll_driver_config_set_actions(VALUE self, VALUE array)
{
    long rindex;
    VALUE row;
    DriverConfig *config;
    long row_count = RARRAY_LEN(array);

    Data_Get_Struct(self, DriverConfig, config);

    config->action_names       = ALLOC_N(VALUE, row_count);
    config->action_arg_amounts = ALLOC_N(long, row_count);

    FOR(rindex, row_count)
    {
        row = rb_ary_entry(array, rindex);

        config->action_names[rindex]       = rb_ary_entry(row, 0);
        config->action_arg_amounts[rindex] = NUM2INT(rb_ary_entry(row, 1));
    }

    config->actions_count = row_count;

    return Qnil;
}

void Init_ll_driver_config()
{
    VALUE mLL   = rb_const_get(rb_cObject, rb_intern("LL"));
    VALUE klass = rb_const_get(mLL, rb_intern("DriverConfig"));

    rb_define_alloc_func(klass, ll_driver_config_allocate);

    rb_define_method(klass, "terminals_native=", ll_driver_config_set_terminals, 1);
    rb_define_method(klass, "rules_native=", ll_driver_config_set_rules, 1);
    rb_define_method(klass, "table_native=", ll_driver_config_set_table, 1);
    rb_define_method(klass, "actions_native=", ll_driver_config_set_actions, 1);
}
