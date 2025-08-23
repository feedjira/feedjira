package org.libll;

import java.util.ArrayList;
import java.util.ArrayDeque;

import org.libll.DriverConfig;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyArray;
import org.jruby.RubySymbol;
import org.jruby.RubyFixnum;

import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.Arity;
import org.jruby.runtime.Helpers;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.BlockCallback;
import org.jruby.runtime.Block;
import org.jruby.runtime.CallBlock19;
import org.jruby.runtime.builtin.IRubyObject;

@JRubyClass(name="LL::Driver", parent="Object")
public class Driver extends RubyObject
{
    private static long T_EOF                = -1;
    private static long T_RULE               = 0;
    private static long T_TERMINAL           = 1;
    private static long T_EPSILON            = 2;
    private static long T_ACTION             = 3;
    private static long T_STAR               = 4;
    private static long T_PLUS               = 5;
    private static long T_ADD_VALUE_STACK    = 6;
    private static long T_APPEND_VALUE_STACK = 7;
    private static long T_QUESTION           = 8;

    /**
     * The current Ruby runtime.
     */
    private Ruby runtime;

    /**
     * The driver configuration.
     */
    private DriverConfig config;

    /**
     * Sets up the class in the Ruby runtime.
     */
    public static void load(Ruby runtime)
    {
        RubyModule ll = (RubyModule) runtime.getModule("LL");

        RubyClass driver = ll.defineClassUnder(
            "Driver",
            runtime.getObject(),
            ALLOCATOR
        );

        driver.defineAnnotatedMethods(Driver.class);
    }

    private static final ObjectAllocator ALLOCATOR = new ObjectAllocator()
    {
        public IRubyObject allocate(Ruby runtime, RubyClass klass)
        {
            return new org.libll.Driver(runtime, klass);
        }
    };

    /**
     * @param runtime The current Ruby runtime.
     * @param klass The Driver class.
     */
    public Driver(Ruby runtime, RubyClass klass)
    {
        super(runtime, klass);

        this.runtime = runtime;
        this.config  = (DriverConfig) klass.getConstant("CONFIG");
    }

    /**
     * The main parsing loop of the driver.
     */
    @JRubyMethod
    public IRubyObject parse(ThreadContext context)
    {
        final ArrayDeque<Long> stack = new ArrayDeque<Long>();
        final ArrayDeque<IRubyObject> value_stack = new ArrayDeque<IRubyObject>();
        final Driver self = this;

        // EOF
        stack.push(this.T_EOF);
        stack.push(this.T_EOF);

        // Start rule
        ArrayList<Long> start_row = self.config.rules.get(0);

        for ( int index = 0; index < start_row.size(); index++ )
        {
            stack.push(start_row.get(index));
        }

        BlockCallback callback = new BlockCallback()
        {
            public IRubyObject call(ThreadContext context, IRubyObject[] args, Block block)
            {
                RubyArray token   = (RubyArray) args[0];
                IRubyObject type  = token.entry(0);
                IRubyObject value = token.entry(1);

                while ( true )
                {
                    if ( stack.size() == 0 )
                    {
                        IRubyObject[] error_args = {
                            RubyFixnum.newFixnum(self.runtime, -1),
                            RubyFixnum.newFixnum(self.runtime, -1),
                            type,
                            value
                        };

                        self.callMethod(context, "parser_error", error_args);
                    }

                    Long stack_value = stack.pop();
                    Long stack_type  = stack.pop();
                    Long token_id    = (long) 0;

                    if ( self.config.terminals.containsKey(type) )
                    {
                        token_id = self.config.terminals.get(type);
                    }

                    // A rule or the "+" operator
                    if ( stack_type == self.T_RULE || stack_type == self.T_PLUS )
                    {
                        Long production_i = self.config.table
                            .get(stack_value.intValue())
                            .get(token_id.intValue());

                        if ( production_i == self.T_EOF )
                        {
                            IRubyObject[] error_args = {
                                RubyFixnum.newFixnum(self.runtime, stack_type),
                                RubyFixnum.newFixnum(self.runtime, stack_value),
                                type,
                                value
                            };

                            self.callMethod(context, "parser_error", error_args);
                        }
                        else
                        {
                            // Append a "*" operator for all following
                            // occurrences as they are optional
                            if ( stack_type == self.T_PLUS )
                            {
                                stack.push(self.T_STAR);
                                stack.push(stack_value);

                                stack.push(self.T_APPEND_VALUE_STACK);
                                stack.push(Long.valueOf(0));
                            }

                            ArrayList<Long> row = self.config.rules
                                .get(production_i.intValue());

                            for ( int index = 0; index < row.size(); index++ )
                            {
                                stack.push(row.get(index));
                            }
                        }
                    }
                    // "*" operator
                    else if ( stack_type == self.T_STAR )
                    {
                        Long production_i = self.config.table
                            .get(stack_value.intValue())
                            .get(token_id.intValue());

                        if ( production_i != self.T_EOF )
                        {
                            stack.push(self.T_STAR);
                            stack.push(stack_value);

                            stack.push(self.T_APPEND_VALUE_STACK);
                            stack.push(Long.valueOf(0));

                            ArrayList<Long> row = self.config.rules
                                .get(production_i.intValue());

                            for ( int index = 0; index < row.size(); index++ )
                            {
                                stack.push(row.get(index));
                            }
                        }
                    }
                    // "?" operator
                    else if ( stack_type == self.T_QUESTION )
                    {
                        Long production_i = self.config.table
                            .get(stack_value.intValue())
                            .get(token_id.intValue());

                        if ( production_i == self.T_EOF )
                        {
                            value_stack.push(context.nil);
                        }
                        else
                        {
                            ArrayList<Long> row = self.config.rules
                                .get(production_i.intValue());

                            for ( int index = 0; index < row.size(); index++ )
                            {
                                stack.push(row.get(index));
                            }
                        }
                    }
                    // Adds a new array to the value stack that can be used to
                    // group operator values together
                    else if ( stack_type == self.T_ADD_VALUE_STACK )
                    {
                        RubyArray operator_buffer = self.runtime.newArray();

                        value_stack.push(operator_buffer);
                    }
                    // Appends the last value on the value stack to the operator
                    // buffer that preceeds it.
                    else if ( stack_type == self.T_APPEND_VALUE_STACK )
                    {
                        IRubyObject last_value    = value_stack.pop();
                        RubyArray operator_buffer = (RubyArray) value_stack.peek();

                        operator_buffer.append(last_value);
                    }
                    // Terminal
                    else if ( stack_type == self.T_TERMINAL )
                    {
                        if ( stack_value == token_id )
                        {
                            value_stack.push(value);

                            break;
                        }
                        else
                        {
                            IRubyObject[] error_args = {
                                RubyFixnum.newFixnum(self.runtime, stack_type),
                                RubyFixnum.newFixnum(self.runtime, stack_value),
                                type,
                                value
                            };

                            self.callMethod(context, "parser_error", error_args);
                        }
                    }
                    // Action
                    else if ( stack_type == self.T_ACTION )
                    {
                        String method = self.config.action_names
                            .get(stack_value.intValue())
                            .toString();

                        long num_args = (long) self.config.action_arg_amounts
                            .get(stack_value.intValue());

                        RubyArray action_args = self.runtime.newArray();

                        if ( num_args > (long) value_stack.size() )
                        {
                            num_args = (long) value_stack.size();
                        }

                        while ( (num_args--) > 0 )
                        {
                            if ( value_stack.size() > 0 )
                            {
                                action_args.store(num_args, value_stack.pop());
                            }
                        }

                        value_stack.push(
                            self.callMethod(context, method, action_args)
                        );
                    }
                    else if ( stack_type == self.T_EOF )
                    {
                        break;
                    }
                }

                return context.nil;
            }
        };

        Helpers.invoke(
            context,
            this,
            "each_token",
            CallBlock19.newCallClosure(
                this,
                this.metaClass,
                Arity.NO_ARGUMENTS,
                callback,
                context
            )
        );

        if ( value_stack.isEmpty() )
        {
            return context.nil;
        }
        else
        {
            return value_stack.pop();
        }
    }
}
