%%machine base_lexer;

%%{
    ##
    # Base grammar for the XML lexer.
    #
    # This grammar is shared between the C and Java extensions. As a result of
    # this you should **not** include language specific code in Ragel
    # actions/callbacks.
    #
    # To call back in to Ruby you can use one of the following two functions:
    #
    # * callback
    # * callback_simple
    #
    # The first function takes 5 arguments:
    #
    # * The name of the Ruby method to call.
    # * The input data.
    # * The encoding of the input data.
    # * The start of the current buffer.
    # * The end of the current buffer.
    #
    # The function callback_simple only takes one argument: the name of the
    # method to call. This function should be used for callbacks that don't
    # require any values.
    #
    # When you call a method in Ruby make sure that said method is defined as
    # an instance method in the `Oga::XML::Lexer` class.
    #
    # The name of the callback to invoke should be an identifier starting with
    # "id_". The identifier should be defined in the associated C and Java code.
    # In case of C code its value should be a Symbol as a ID object, for Java
    # it should be a String. For example:
    #
    #     ID id_foo = rb_intern("foo");
    #
    # And for Java:
    #
    #     String id_foo = "foo";
    #
    # ## Machine Transitions
    #
    # To transition from one machine to another always use `fnext` instead of
    # `fcall` and `fret`. This removes the need for the code to keep track of a
    # stack.
    #

    newline    = '\r\n' | '\n' | '\r';
    whitespace = [ \t];

    unicode    = any - ascii;
    ident_char = unicode | [a-zA-Z0-9\-_\.];
    identifier = ident_char+;

    html_ident_char = unicode | [a-zA-Z0-9\-_\.:];
    html_identifier = html_ident_char+;

    whitespace_or_newline = whitespace | newline;

    action count_newlines {
        if ( fc == '\n' ) lines++;
    }

    action advance_newline {
        advance_line(1);
    }

    action hold_and_return {
        fhold;
        fret;
    }

    # Comments
    #
    # http://www.w3.org/TR/html/syntax.html#comments
    #
    # Unlike the W3C specification these rules *do* allow character sequences
    # such as `--` and `->`. Putting extra checks in for these sequences would
    # actually make the rules/actions more complex.
    #

    comment_start = '<!--';
    comment_end   = '-->';

    # Everything except "-" OR a single "-"
    comment_allowed = (^'-'+ | '-') $count_newlines;

    action start_comment {
        callback_simple(id_on_comment_start);

        fnext comment_body;
    }

    comment_body := |*
        comment_allowed => {
            callback(id_on_comment_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        };

        comment_end => {
            callback_simple(id_on_comment_end);

            fnext main;
        };
    *|;

    # CDATA
    #
    # http://www.w3.org/TR/html/syntax.html#cdata-sections
    #
    # In HTML CDATA tags have no meaning/are not supported. Oga does
    # support them but treats their contents as plain text.
    #

    cdata_start = '<![CDATA[';
    cdata_end   = ']]>';

    # Everything except "]" OR a single "]"
    cdata_allowed = (^']'+ | ']') $count_newlines;

    action start_cdata {
        callback_simple(id_on_cdata_start);

        fnext cdata_body;
    }

    cdata_body := |*
        cdata_allowed => {
            callback(id_on_cdata_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        };

        cdata_end => {
            callback_simple(id_on_cdata_end);

            fnext main;
        };
    *|;

    # Processing Instructions
    #
    # http://www.w3.org/TR/xpath/#section-Processing-Instruction-Nodes
    # http://en.wikipedia.org/wiki/Processing_Instruction
    #
    # These are tags meant to be used by parsers/libraries for custom behaviour.
    # One example are the tags used by PHP: <?php and ?>. Note that the XML
    # declaration tags (<?xml ?>) are not considered to be a processing
    # instruction.
    #

    proc_ins_start = '<?' identifier (':' identifier)?;
    proc_ins_end   = '?>';

    # Everything except "?" OR a single "?"
    proc_ins_allowed = (^'?'+ | '?') $count_newlines;

    action start_proc_ins {
        callback_simple(id_on_proc_ins_start);
        callback(id_on_proc_ins_name, data, encoding, ts + 2, te);

        fnext proc_ins_body;
    }

    proc_ins_body := |*
        proc_ins_allowed => {
            callback(id_on_proc_ins_body, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        };

        proc_ins_end => {
            callback_simple(id_on_proc_ins_end);

            fnext main;
        };
    *|;

    # Strings
    #
    # Strings in HTML can either be single or double quoted. If a string
    # starts with one of these quotes it must be closed with the same type
    # of quote.
    #
    dquote = '"';
    squote = "'";

    action emit_string {
        callback(id_on_string_body, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }

    action start_string_squote {
        callback_simple(id_on_string_squote);

        fcall string_squote;
    }

    action start_string_dquote {
        callback_simple(id_on_string_dquote);

        fcall string_dquote;
    }

    string_squote := |*
        ^squote* $count_newlines => emit_string;

        squote => {
            callback_simple(id_on_string_squote);

            fret;
        };
    *|;

    string_dquote := |*
        ^dquote* $count_newlines => emit_string;

        dquote => {
            callback_simple(id_on_string_dquote);

            fret;
        };
    *|;

    # DOCTYPES
    #
    # http://www.w3.org/TR/html/syntax.html#the-doctype
    #
    # These rules support the 3 flavours of doctypes:
    #
    # 1. Normal doctypes, as introduced in the HTML5 specification.
    # 2. Deprecated doctypes, the more verbose ones used prior to HTML5.
    # 3. Legacy doctypes
    #
    doctype_start = '<!DOCTYPE'i (whitespace_or_newline+ $count_newlines);

    action start_doctype {
        callback_simple(id_on_doctype_start);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }

        fnext doctype;
    }

    # Machine for processing inline rules of a doctype.
    doctype_inline := |*
        ^']'* $count_newlines => {
            callback(id_on_doctype_inline, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }
        };

        ']' => { fnext doctype; };
    *|;

    # Machine for processing doctypes. Doctype values such as the public
    # and system IDs are treated as T_STRING tokens.
    doctype := |*
        'PUBLIC'i | 'SYSTEM'i => {
            callback(id_on_doctype_type, data, encoding, ts, te);
        };

        # Starts a set of inline doctype rules.
        '[' => { fnext doctype_inline; };

        # Lex the public/system IDs as regular strings.
        squote => start_string_squote;
        dquote => start_string_dquote;

        identifier => {
            callback(id_on_doctype_name, data, encoding, ts, te);
        };

        '>' => {
            callback_simple(id_on_doctype_end);
            fnext main;
        };

        newline => advance_newline;

        whitespace;
    *|;

    # XML declaration tags
    #
    # http://www.w3.org/TR/REC-xml/#sec-prolog-dtd
    #
    xml_decl_start = '<?xml';
    xml_decl_end   = '?>';

    action start_xml_decl {
        callback_simple(id_on_xml_decl_start);
        fnext xml_decl;
    }

    # Machine that processes the contents of an XML declaration tag.
    xml_decl := |*
        xml_decl_end => {
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            callback_simple(id_on_xml_decl_end);

            fnext main;
        };

        # Attributes and their values (e.g. version="1.0").
        identifier => {
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            callback(id_on_attribute, data, encoding, ts, te);
        };

        squote => start_string_squote;
        dquote => start_string_dquote;

        any $count_newlines;
    *|;

    # Elements
    #
    # http://www.w3.org/TR/html/syntax.html#syntax-elements
    #
    # Lexing of elements is broken up into different machines that handle the
    # name/namespace, contents of the open tag and the body of an element. The
    # body of an element is lexed using the `main` machine.
    #

    action start_element {
        fhold;
        fnext element_name;
    }

    action start_close_element {
        fnext element_close;
    }

    action close_element {
        callback(id_on_element_end, data, encoding, ts, te);
    }

    action close_element_fnext_main {
        callback_simple(id_on_element_end);

        fnext main;
    }

    element_start = '<' ident_char;
    element_end   = '</';
    element_start_pattern = '<' identifier (':' identifier)?;

    # Machine used for lexing the name/namespace of an element.
    element_name := |*
        identifier ':' => {
            if ( !html_p )
            {
                callback(id_on_element_ns, data, encoding, ts, te - 1);
            }
        };

        identifier => {
            callback(id_on_element_name, data, encoding, ts, te);

            if ( html_p )
            {
                fnext html_element_head;
            }
            else
            {
                fnext element_head;
            }
        };
    *|;

    # Machine used for lexing the closing tag of an element
    element_close := |*
        # namespace prefixes, currently not used but allows the rule below it
        # to be used for the actual element name.
        identifier ':';

        identifier => close_element;

        '>' => {
            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            fnext main;
        };

        any $count_newlines;
    *|;

    # Machine used after matching the "=" of an attribute and just before moving
    # into the actual attribute value.
    attribute_pre := |*
        whitespace_or_newline $count_newlines;

        squote | dquote => {
            fhold;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            fnext quoted_attribute_value;
        };

        any => {
            fhold;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            if ( html_p )
            {
                fnext unquoted_attribute_value;
            }
            /* XML doesn't support unquoted attribute values */
            else
            {
                fret;
            }
        };
    *|;

    # Machine for processing unquoted HTML attribute values.
    #
    # The HTML specification describes a set of characters that can be allowed
    # in an unquoted value at https://html.spec.whatwg.org/multipage/introduction.html#intro-early-example.
    #
    # As is always the case with HTML everybody completely ignores this
    # specification and thus every library and browser out these is expected to
    # support input such as `<a href=lol("javascript","is","great")></a>.
    #
    # Oga too has to support this, thus the only characters it disallows in
    # unquoted attribute values are:
    #
    # * > (used for terminating open tags)
    # * whitespace
    #
    unquoted_attribute_value := |*
        ^('>' | whitespace_or_newline)+ => {
            callback_simple(id_on_string_squote);

            callback(id_on_string_body, data, encoding, ts, te);

            callback_simple(id_on_string_squote);
        };

        any => hold_and_return;
    *|;

    # Machine used for processing quoted XML/HTML attribute values.
    quoted_attribute_value := |*
        # The following two actions use "fnext" instead of "fcall". Combined
        # with "element_head" using "fcall" to jump to this machine this means
        # we can return back to "element_head" after processing a single string.
        squote => {
            callback_simple(id_on_string_squote);

            fnext string_squote;
        };

        dquote => {
            callback_simple(id_on_string_dquote);

            fnext string_dquote;
        };

        any => hold_and_return;
    *|;

    action start_attribute_pre {
        fcall attribute_pre;
    }

    action close_open_element {
        callback_simple(id_on_element_open_end);

        if ( html_script_p() )
        {
            fnext html_script;
        }
        else if ( html_style_p() )
        {
            fnext html_style;
        }
        else
        {
            fnext main;
        }
    }

    action close_self_closing_element {
        callback_simple(id_on_element_end);
        fnext main;
    }

    # Machine used for processing the contents of an XML element's starting tag.
    element_head := |*
        newline => advance_newline;
        element_start_pattern;

        # Attribute names and namespaces.
        identifier ':' => {
            callback(id_on_attribute_ns, data, encoding, ts, te - 1);
        };

        identifier => {
            callback(id_on_attribute, data, encoding, ts, te);
        };

        '=' => start_attribute_pre;

        '>' => {
            callback_simple(id_on_element_open_end);

            fnext main;
        };

        '/>' => close_self_closing_element;

        any;
    *|;

    # Machine used for processing the contents of an HTML element's starting
    # tag.
    html_element_head := |*
        newline => advance_newline;
        element_start_pattern;

        html_identifier => {
            callback(id_on_attribute, data, encoding, ts, te);
        };

        '=' => start_attribute_pre;

        '>' => {
            callback_simple(id_on_element_open_end);

            if ( html_script_p() )
            {
                fnext html_script;
            }
            else if ( html_style_p() )
            {
                fnext html_style;
            }
            else
            {
                fnext main;
            }
        };

        '/>' => close_self_closing_element;

        any;
    *|;

    # Text
    #
    # http://www.w3.org/TR/xml/#syntax
    # http://www.w3.org/TR/html/syntax.html#text
    #
    # Text content is everything leading up to certain special tags such as "</"
    # and "<?".

    action start_text {
        fhold;
        fnext text;
    }

    # These characters terminate a T_TEXT sequence and instruct Ragel to jump
    # back to the main machine.
    #
    # Note that this only works if each sequence is exactly 2 characters
    # long. Because of this "<!" is used instead of "<!--".

    terminate_text = '</' | '<!' | '<?' | element_start;
    allowed_text   = (any* -- terminate_text) $count_newlines;

    action emit_text {
        callback(id_on_text, data, encoding, ts, te);

        if ( lines > 0 )
        {
            advance_line(lines);

            lines = 0;
        }
    }

    text := |*
        terminate_text | allowed_text => {
            callback(id_on_text, data, encoding, ts, te);

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            fnext main;
        };

        # Text followed by a special tag, such as "foo<!--"
        allowed_text %{ mark = p; } terminate_text => {
            callback(id_on_text, data, encoding, ts, mark);

            p    = mark - 1;
            mark = 0;

            if ( lines > 0 )
            {
                advance_line(lines);

                lines = 0;
            }

            fnext main;
        };
    *|;

    # Certain tags in HTML can contain basically anything except for the literal
    # closing tag. Two examples are script and style tags.  As a result of this
    # we can't use the regular text machine.

    literal_html_allowed = (^'<'+ | '<'+) $count_newlines;

    html_script := |*
        literal_html_allowed => emit_text;
        '</script>'          => close_element_fnext_main;
    *|;

    html_style := |*
        literal_html_allowed => emit_text;
        '</style>'           => close_element_fnext_main;
    *|;

    # The main machine aka the entry point of Ragel.
    main := |*
        doctype_start  => start_doctype;
        xml_decl_start => start_xml_decl;
        comment_start  => start_comment;
        cdata_start    => start_cdata;
        proc_ins_start => start_proc_ins;
        element_start  => start_element;
        element_end    => start_close_element;
        any            => start_text;
    *|;
}%%
