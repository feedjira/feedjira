#include "driver.h"

#define T_EOF -1
#define T_RULE 0
#define T_TERMINAL 1
#define T_EPSILON 2
#define T_ACTION 3
#define T_STAR 4
#define T_PLUS 5
#define T_ADD_VALUE_STACK 6
#define T_APPEND_VALUE_STACK 7
#define T_QUESTION 8

ID id_config_const;
ID id_each_token;
ID id_send;
ID id_parser_error;

/**
 * Releases the memory of the driver's internal state and associated objects.
 * This function is called automatically when a Driver instance is garbage
 * collected.
 */
void ll_driver_free(DriverState *state)
{
    kv_destroy(state->stack);
    kv_destroy(state->value_stack);

    free(state);
}

/**
 * Marks the objects stored in the driver's internal state, preventing them from
 * being garbage collected until the next GC run.
 */
void ll_driver_mark(DriverState *state)
{
    size_t index;

    FOR(index, kv_size(state->value_stack))
    {
        rb_gc_mark(kv_A(state->value_stack, index));
    }
}

/**
 * Allocates a new instance of the Driver class and prepares its internal state.
 */
VALUE ll_driver_allocate(VALUE klass)
{
    DriverState *state = ALLOC(DriverState);
    VALUE config       = rb_const_get(klass, id_config_const);

    Data_Get_Struct(config, DriverConfig, state->config);

    kv_init(state->stack);
    kv_init(state->value_stack);

    return Data_Wrap_Struct(klass, ll_driver_mark, ll_driver_free, state);
}

/**
 * Callback function for iterating over every input token and actually parsing
 * said input.
 *
 * @param token An Array containing the token type as a Symbol and its value.
 * @param self The Driver instance currently in use.
 */
VALUE ll_driver_each_token(VALUE token, VALUE self)
{
    VALUE method;
    VALUE action_args;
    VALUE action_retval;
    VALUE operator_buffer;
    VALUE last_value;
    long num_args;
    long args_i;

    long token_id;

    long rule_i;
    long production_i;

    long stack_type;
    long stack_value;

    DriverState *state;

    VALUE type  = rb_ary_entry(token, 0);
    VALUE value = rb_ary_entry(token, 1);

    Data_Get_Struct(self, DriverState, state);

    while ( 1 )
    {
        if ( kv_size(state->stack) == 0 )
        {
            rb_funcall(
                self,
                id_parser_error,
                4,
                INT2NUM(-1),
                INT2NUM(-1),
                type,
                value
            );
        }

        stack_value = kv_pop(state->stack);
        stack_type  = kv_pop(state->stack);
        token_id    = 0;

        if ( TYPE(type) == T_SYMBOL )
        {
            khint64_t found = kh_get(int64_map, state->config->terminals, type);

            if ( found != kh_end(state->config->terminals) )
            {
                token_id = kh_value(state->config->terminals, found);
            }
        }

        /* A rule or the "+" operator */
        if ( stack_type == T_RULE || stack_type == T_PLUS )
        {
            production_i = state->config->table[stack_value][token_id];

            if ( production_i == T_EOF )
            {
                rb_funcall(
                    self,
                    id_parser_error,
                    4,
                    INT2NUM(stack_type),
                    INT2NUM(stack_value),
                    type,
                    value
                );
            }
            else
            {
                /*
                Append a "*" operator for all following occurrences as they are
                optional
                */
                if ( stack_type == T_PLUS )
                {
                    kv_push(long, state->stack, T_STAR);
                    kv_push(long, state->stack, stack_value);

                    kv_push(long, state->stack, T_APPEND_VALUE_STACK);
                    kv_push(long, state->stack, 0);
                }

                FOR(rule_i, state->config->rule_lengths[production_i])
                {
                    kv_push(
                        long,
                        state->stack,
                        state->config->rules[production_i][rule_i]
                    );
                }
            }
        }
        /* "*" operator */
        else if ( stack_type == T_STAR )
        {
            production_i = state->config->table[stack_value][token_id];

            if ( production_i != T_EOF )
            {
                kv_push(long, state->stack, T_STAR);
                kv_push(long, state->stack, stack_value);

                kv_push(long, state->stack, T_APPEND_VALUE_STACK);
                kv_push(long, state->stack, 0);

                FOR(rule_i, state->config->rule_lengths[production_i])
                {
                    kv_push(
                        long,
                        state->stack,
                        state->config->rules[production_i][rule_i]
                    );
                }
            }
        }
        /* "?" operator */
        else if ( stack_type == T_QUESTION )
        {
            production_i = state->config->table[stack_value][token_id];

            if ( production_i == T_EOF )
            {
                kv_push(VALUE, state->value_stack, Qnil);
            }
            else
            {
                FOR(rule_i, state->config->rule_lengths[production_i])
                {
                    kv_push(
                        long,
                        state->stack,
                        state->config->rules[production_i][rule_i]
                    );
                }
            }
        }
        /*
        Adds a new array to the value stack that can be used to group operator
        values together
        */
        else if ( stack_type == T_ADD_VALUE_STACK )
        {
            operator_buffer = rb_ary_new();

            kv_push(VALUE, state->value_stack, operator_buffer);

            RB_GC_GUARD(operator_buffer);
        }
        /*
        Appends the last value on the value stack to the operator buffer that
        preceeds it.
        */
        else if ( stack_type == T_APPEND_VALUE_STACK )
        {
            last_value = kv_pop(state->value_stack);

            operator_buffer = kv_A(
                state->value_stack,
                kv_size(state->value_stack) - 1
            );

            rb_ary_push(operator_buffer, last_value);
        }
        /* Terminal */
        else if ( stack_type == T_TERMINAL )
        {
            if ( stack_value == token_id )
            {
                kv_push(VALUE, state->value_stack, value);

                RB_GC_GUARD(value);

                break;
            }
            else
            {
                rb_funcall(
                    self,
                    id_parser_error,
                    4,
                    INT2NUM(stack_type),
                    INT2NUM(stack_value),
                    type,
                    value
                );
            }
        }
        /* Action */
        else if ( stack_type == T_ACTION )
        {
            method      = state->config->action_names[stack_value];
            num_args    = state->config->action_arg_amounts[stack_value];
            action_args = rb_ary_new2(num_args);
            args_i      = num_args;

            if ( args_i > (long) kv_size(state->value_stack) )
            {
                args_i = (long) kv_size(state->value_stack);
            }

            while ( args_i-- )
            {
                if ( kv_size(state->value_stack) > 0 )
                {
                    rb_ary_store(
                        action_args,
                        args_i,
                        kv_pop(state->value_stack)
                    );
                }
            }

            action_retval = rb_funcall(self, id_send, 2, method, action_args);

            kv_push(VALUE, state->value_stack, action_retval);

            RB_GC_GUARD(action_retval);
        }
        /* EOF */
        else if ( stack_type == T_EOF )
        {
            break;
        }
    }

    return Qnil;
}

/**
 * Starts the parser.
 *
 * @param self The Driver instance the "parse" method was called on.
 */
VALUE ll_driver_parse(VALUE self)
{
    long index;

    DriverState *state;

    Data_Get_Struct(self, DriverState, state);

    /* EOF rule */
    kv_push(long, state->stack, T_EOF);
    kv_push(long, state->stack, T_EOF);

    /* Start rule */
    FOR(index, state->config->rule_lengths[0])
    {
        kv_push(long, state->stack, state->config->rules[0][index]);
    }

    rb_block_call(
        self,
        id_each_token,
        0,
        NULL,
        RUBY_METHOD_FUNC(ll_driver_each_token),
        self
    );

    if ( kv_size(state->value_stack) == 0 )
    {
        return Qnil;
    }
    else
    {
        return kv_pop(state->value_stack);
    }
}

void Init_ll_driver()
{
    VALUE mLL     = rb_const_get(rb_cObject, rb_intern("LL"));
    VALUE cDriver = rb_const_get(mLL, rb_intern("Driver"));

    rb_define_method(cDriver, "parse", ll_driver_parse, 0);

    rb_define_alloc_func(cDriver, ll_driver_allocate);

    id_send         = rb_intern("send");
    id_config_const = rb_intern("CONFIG");
    id_each_token   = rb_intern("each_token");
    id_parser_error = rb_intern("parser_error");
}
