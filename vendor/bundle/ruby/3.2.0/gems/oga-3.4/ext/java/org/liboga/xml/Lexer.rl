package org.liboga.xml;

%%machine java_lexer;

import java.io.IOException;

import org.jcodings.Encoding;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyString;
import org.jruby.RubyFixnum;
import org.jruby.util.ByteList;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.builtin.IRubyObject;

/**
 * Lexer support class for JRuby.
 *
 * The Lexer class contains the raw Ragel loop and calls back in to Ruby land
 * whenever a Ragel action is needed similar to the C extension setup.
 *
 * This class requires Ruby land to first define the `Oga::XML` namespace.
 */
@JRubyClass(name="Oga::XML::Lexer", parent="Object")
public class Lexer extends RubyObject
{
    /**
     * The current Ruby runtime.
     */
    private Ruby runtime;

    %% write data;

    /* Used by Ragel to keep track of the current state. */
    int act;
    int cs;
    int top;
    int lines;
    int[] stack;

    /**
     * Sets up the current class in the Ruby runtime.
     */
    public static void load(Ruby runtime)
    {
        RubyModule xml = (RubyModule) runtime.getModule("Oga")
            .getConstant("XML");

        RubyClass lexer = xml.defineClassUnder(
            "Lexer",
            runtime.getObject(),
            ALLOCATOR
        );

        lexer.defineAnnotatedMethods(Lexer.class);
    }

    private static final ObjectAllocator ALLOCATOR = new ObjectAllocator()
    {
        public IRubyObject allocate(Ruby runtime, RubyClass klass)
        {
            return new org.liboga.xml.Lexer(runtime, klass);
        }
    };

    public Lexer(Ruby runtime, RubyClass klass)
    {
        super(runtime, klass);

        this.runtime = runtime;
    }

    /**
     * Runs the bulk of the Ragel loop and calls back in to Ruby.
     *
     * This method pulls its data in from the instance variable `@data`. The
     * Ruby side of the Lexer class should set this variable to a String in its
     * constructor method. Encodings are passed along to make sure that token
     * values share the same encoding as the input.
     *
     * This method always returns nil.
     */
    @JRubyMethod
    public IRubyObject advance_native(ThreadContext context, RubyString rb_str)
    {
        Boolean html_p = this.callMethod(context, "html?").isTrue();

        Encoding encoding = rb_str.getEncoding();

        byte[] data = rb_str.getBytes();

        int ts    = 0;
        int te    = 0;
        int p     = 0;
        int mark  = 0;
        int lines = this.lines;
        int pe    = data.length;
        int eof   = data.length;

        String id_advance_line        = "advance_line";
        String id_on_attribute        = "on_attribute";
        String id_on_attribute_ns     = "on_attribute_ns";
        String id_on_cdata_start      = "on_cdata_start";
        String id_on_cdata_body       = "on_cdata_body";
        String id_on_cdata_end        = "on_cdata_end";
        String id_on_comment_start    = "on_comment_start";
        String id_on_comment_body     = "on_comment_body";
        String id_on_comment_end      = "on_comment_end";
        String id_on_doctype_end      = "on_doctype_end";
        String id_on_doctype_inline   = "on_doctype_inline";
        String id_on_doctype_name     = "on_doctype_name";
        String id_on_doctype_start    = "on_doctype_start";
        String id_on_doctype_type     = "on_doctype_type";
        String id_on_element_end      = "on_element_end";
        String id_on_element_name     = "on_element_name";
        String id_on_element_ns       = "on_element_ns";
        String id_on_element_open_end = "on_element_open_end";
        String id_on_proc_ins_end     = "on_proc_ins_end";
        String id_on_proc_ins_name    = "on_proc_ins_name";
        String id_on_proc_ins_start   = "on_proc_ins_start";
        String id_on_proc_ins_body    = "on_proc_ins_body";
        String id_on_string_body      = "on_string_body";
        String id_on_string_dquote    = "on_string_dquote";
        String id_on_string_squote    = "on_string_squote";
        String id_on_text             = "on_text";
        String id_on_xml_decl_end     = "on_xml_decl_end";
        String id_on_xml_decl_start   = "on_xml_decl_start";

        %% write exec;

        this.lines = lines;

        return context.nil;
    }

    /**
     * Resets the internal state of the lexer.
     */
    @JRubyMethod
    public IRubyObject reset_native(ThreadContext context)
    {
        this.act   = 0;
        this.top   = 0;
        this.stack = new int[4];
        this.cs    = java_lexer_start;

        return context.nil;
    }

    /**
     * Calls back in to Ruby land passing the current token value along.
     *
     * This method calls back in to Ruby land based on the method name
     * specified in `name`. The Ruby callback should take one argument. This
     * argument will be a String containing the value of the current token.
     */
    public void callback(String name, byte[] data, Encoding enc, int ts, int te)
    {
        ByteList bytelist = new ByteList(data, ts, te - ts, enc, true);

        RubyString value = this.runtime.newString(bytelist);

        ThreadContext context = this.runtime.getCurrentContext();

        this.callMethod(context, name, value);
    }

    /**
     * Calls back in to Ruby land without passing any arguments.
     */
    public void callback_simple(String name)
    {
        ThreadContext context = this.runtime.getCurrentContext();

        this.callMethod(context, name);
    }

    /**
     * Advances the line number by `amount` lines.
     */
    public void advance_line(int amount)
    {
        ThreadContext context = this.runtime.getCurrentContext();
        RubyFixnum lines      = this.runtime.newFixnum(amount);

        this.callMethod(context, "advance_line", lines);
    }

    /**
     * @see Oga::XML::Lexer#html_script?
     */
    public Boolean html_script_p()
    {
        ThreadContext context = this.runtime.getCurrentContext();

        return this.callMethod(context, "html_script?").isTrue();
    }

    /**
     * @see Oga::XML::Lexer#html_style?
     */
    public Boolean html_style_p()
    {
        ThreadContext context = this.runtime.getCurrentContext();

        return this.callMethod(context, "html_style?").isTrue();
    }
}

%%{
    variable act this.act;
    variable cs this.cs;
    variable stack this.stack;
    variable top this.top;

    include base_lexer "base_lexer.rl";
}%%
