package org.libll;

import java.util.HashMap;
import java.util.ArrayList;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubySymbol;
import org.jruby.RubyArray;
import org.jruby.RubyFixnum;

import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.builtin.IRubyObject;

/**
 * Class used for storing the configuration (e.g. the rules and the lookup
 * table) of a parser driver. This class mimics its C equivalent (also called
 * "DriverConfig").
 */
@JRubyClass(name="LL::DriverConfig", parent="Object")
public class DriverConfig extends RubyObject
{
    /**
     * The current Ruby runtime.
     */
    private Ruby runtime;

    /**
     * Hash mapping Ruby Symbols with their indexes.
     */
    public HashMap<RubySymbol, Long> terminals = new HashMap<RubySymbol, Long>();

    /**
     * 2-dimensional array containing the rules and their steps.
     */
    public ArrayList<ArrayList<Long>> rules = new ArrayList<ArrayList<Long>>();

    /**
     * 2-dimensional array used as the lookup table.
     */
    public ArrayList<ArrayList<Long>> table = new ArrayList<ArrayList<Long>>();

    /**
     * Array containing the callback names.
     */
    public ArrayList<RubySymbol> action_names = new ArrayList<RubySymbol>();

    /**
     * Array containing the arities of every callback.
     */
    public ArrayList<Integer> action_arg_amounts = new ArrayList<Integer>();

    /**
     * Sets up the class in the Ruby runtime.
     */
    public static void load(Ruby runtime)
    {
        RubyModule ll = (RubyModule) runtime.getModule("LL");

        RubyClass config = ll.defineClassUnder(
            "DriverConfig",
            runtime.getObject(),
            ALLOCATOR
        );

        config.defineAnnotatedMethods(DriverConfig.class);
    }

    private static final ObjectAllocator ALLOCATOR = new ObjectAllocator()
    {
        public IRubyObject allocate(Ruby runtime, RubyClass klass)
        {
            return new org.libll.DriverConfig(runtime, klass);
        }
    };

    /**
     * @param runtime The current Ruby runtime.
     * @param klass The DriverConfig class.
     */
    public DriverConfig(Ruby runtime, RubyClass klass)
    {
        super(runtime, klass);

        this.runtime = runtime;
    }

    /**
     * Stores the terminals of the parser in the current DriverConfig instance.
     *
     * @param arg Array of terminals to store.
     */
    @JRubyMethod(name="terminals_native=")
    public IRubyObject set_terminals_native(ThreadContext context, IRubyObject arg)
    {
        RubyArray array = arg.convertToArray();

        for ( long index = 0; index < array.size(); index++ )
        {
            RubySymbol sym = (RubySymbol) array.entry(index);

            this.terminals.put(sym, index);
        }

        return context.nil;
    }

    /**
     * Stores the rules in the current DriverConfig instance.
     *
     * @param arg Array of rules to store.
     */
    @JRubyMethod(name="rules_native=")
    public IRubyObject set_rules_native(ThreadContext context, IRubyObject arg)
    {
        RubyArray array = arg.convertToArray();

        for ( long rindex = 0; rindex < array.size(); rindex++ )
        {
            RubyArray ruby_row  = (RubyArray) array.entry(rindex);
            ArrayList<Long> row = new ArrayList<Long>();

            for ( long cindex = 0; cindex < ruby_row.size(); cindex++ )
            {
                RubyFixnum column = (RubyFixnum) ruby_row.entry(cindex);

                row.add(column.getLongValue());
            }

            this.rules.add(row);
        }

        return context.nil;
    }

    /**
     * Stores the lookup table in the current DriverConfig instance.
     *
     * @param arg Array containing the rows/columns of the lookup table.
     */
    @JRubyMethod(name="table_native=")
    public IRubyObject set_table_native(ThreadContext context, IRubyObject arg)
    {
        RubyArray array = arg.convertToArray();

        for ( long rindex = 0; rindex < array.size(); rindex++ )
        {
            RubyArray ruby_row  = (RubyArray) array.entry(rindex);
            ArrayList<Long> row = new ArrayList<Long>();

            for ( long cindex = 0; cindex < ruby_row.size(); cindex++ )
            {
                RubyFixnum column = (RubyFixnum) ruby_row.entry(cindex);

                row.add(column.getLongValue());
            }

            this.table.add(row);
        }

        return context.nil;
    }

    /**
     * Stores the callback actions and their arities in the current DriverConfig
     * instance.
     *
     * @param arg Array containing the callback names and their arguments.
     */
    @JRubyMethod(name="actions_native=")
    public IRubyObject set_actions_native(ThreadContext context, IRubyObject arg)
    {
        RubyArray array = arg.convertToArray();

        for ( long rindex = 0; rindex < array.size(); rindex++ )
        {
            RubyArray row = (RubyArray) array.entry(rindex);

            RubySymbol name  = (RubySymbol) row.entry(0);
            RubyFixnum arity = (RubyFixnum) row.entry(1);

            this.action_names.add(name);
            this.action_arg_amounts.add((int) arity.getLongValue());
        }

        return context.nil;
    }
}
