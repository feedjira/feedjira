module Oga
  module XML
    # Low level lexer that supports both XML and HTML (using an extra option).
    # To lex HTML input set the `:html` option to `true` when creating an
    # instance of the lexer:
    #
    #     lexer = Oga::XML::Lexer.new(:html => true)
    #
    # This lexer can process both String and IO instances. IO instances are
    # processed on a line by line basis. This can greatly reduce memory usage
    # in exchange for a slightly slower runtime.
    #
    # ## Thread Safety
    #
    # Since this class keeps track of an internal state you can not use the
    # same instance between multiple threads at the same time. For example, the
    # following will not work reliably:
    #
    #     # Don't do this!
    #     lexer   = Oga::XML::Lexer.new('....')
    #     threads = []
    #
    #     2.times do
    #       threads << Thread.new do
    #         lexer.advance do |*args|
    #           p args
    #         end
    #       end
    #     end
    #
    #     threads.each(&:join)
    #
    # However, it is perfectly save to use different instances per thread.
    # There is no _global_ state used by this lexer.
    #
    # ## Strict Mode
    #
    # By default the lexer is rather permissive regarding the input. For
    # example, missing closing tags are inserted by default. To disable this
    # behaviour the lexer can be run in "strict mode" by setting `:strict` to
    # `true`:
    #
    #     lexer = Oga::XML::Lexer.new('...', :strict => true)
    #
    # Strict mode only applies to XML documents.
    #
    # @private
    class Lexer
      # These are all constant/frozen to remove the need for String allocations
      # every time they are referenced in the lexer.
      HTML_SCRIPT = 'script'.freeze
      HTML_STYLE  = 'style'.freeze

      # Elements that are allowed directly in a <table> element.
      HTML_TABLE_ALLOWED = Whitelist.new(
        %w{thead tbody tfoot tr caption colgroup col}
      )

      HTML_SCRIPT_ELEMENTS = Whitelist.new(%w{script template})

      # The elements that may occur in a thead, tbody, or tfoot.
      #
      # Technically "th" is not allowed per the HTML5 spec, but it's so commonly
      # used in these elements that we allow it anyway.
      HTML_TABLE_ROW_ELEMENTS = Whitelist.new(%w{tr th}) + HTML_SCRIPT_ELEMENTS

      # Elements that should be closed automatically before a new opening tag is
      # processed.
      HTML_CLOSE_SELF = {
        'head' => Blacklist.new(%w{head body}),
        'body' => Blacklist.new(%w{head body}),
        'li'   => Blacklist.new(%w{li}),
        'dt'   => Blacklist.new(%w{dt dd}),
        'dd'   => Blacklist.new(%w{dt dd}),
        'p'    => Blacklist.new(%w{
          address article aside blockquote details div dl fieldset figcaption
          figure footer form h1 h2 h3 h4 h5 h6 header hgroup hr main menu nav
          ol p pre section table ul
        }),
        'rb'       => Blacklist.new(%w{rb rt rtc rp}),
        'rt'       => Blacklist.new(%w{rb rt rtc rp}),
        'rtc'      => Blacklist.new(%w{rb rtc}),
        'rp'       => Blacklist.new(%w{rb rt rtc rp}),
        'optgroup' => Blacklist.new(%w{optgroup}),
        'option'   => Blacklist.new(%w{optgroup option}),
        'colgroup' => Whitelist.new(%w{col template}),
        'caption'  => HTML_TABLE_ALLOWED.to_blacklist,
        'table'    => HTML_TABLE_ALLOWED + HTML_SCRIPT_ELEMENTS,
        'thead'    => HTML_TABLE_ROW_ELEMENTS,
        'tbody'    => HTML_TABLE_ROW_ELEMENTS,
        'tfoot'    => HTML_TABLE_ROW_ELEMENTS,
        'tr'       => Whitelist.new(%w{td th}) + HTML_SCRIPT_ELEMENTS,
        'td'       => Blacklist.new(%w{td th}) + HTML_TABLE_ALLOWED,
        'th'       => Blacklist.new(%w{td th}) + HTML_TABLE_ALLOWED
      }

      HTML_CLOSE_SELF.keys.each do |key|
        HTML_CLOSE_SELF[key.upcase] = HTML_CLOSE_SELF[key]
      end

      # Names of HTML tags of which the content should be lexed as-is.
      LITERAL_HTML_ELEMENTS = Whitelist.new([HTML_SCRIPT, HTML_STYLE])

      # @param [String|IO] data The data to lex. This can either be a String or
      #  an IO instance.
      #
      # @param [Hash] options
      #
      # @option options [TrueClass|FalseClass] :html When set to `true` the
      #  lexer will treat the input as HTML instead of XML. This makes it
      #  possible to lex HTML void elements such as `<link href="">`.
      #
      # @option options [TrueClass|FalseClass] :strict Enables/disables strict
      #  parsing of XML documents, disabled by default.
      def initialize(data, options = {})
        @data   = data
        @html   = options[:html]
        @strict = options[:strict] || false
        @line     = 1
        @elements = []
        reset_native
      end

      # Yields the data to lex to the supplied block.
      #
      # @return [String]
      # @yieldparam [String]
      def read_data
        if @data.is_a?(String)
          yield @data

        # IO, StringIO, etc
        # THINK: read(N) would be nice, but currently this screws up the C code
        elsif @data.respond_to?(:each_line)
          @data.each_line { |line| yield line }

        # Enumerator, Array, etc
        elsif @data.respond_to?(:each)
          @data.each { |chunk| yield chunk }
        end
      end

      # Gathers all the tokens for the input and returns them as an Array.
      #
      # @see #advance
      # @return [Array]
      def lex
        tokens = []

        advance do |type, value, line|
          tokens << [type, value, line]
        end

        tokens
      end

      # Advances through the input and generates the corresponding tokens. Each
      # token is yielded to the supplied block.
      #
      # Each token is an Array in the following format:
      #
      #     [TYPE, VALUE]
      #
      # The type is a symbol, the value is either nil or a String.
      #
      # This method stores the supplied block in `@block` and resets it after
      # the lexer loop has finished.
      #
      # @yieldparam [Symbol] type
      # @yieldparam [String] value
      # @yieldparam [Fixnum] line
      def advance(&block)
        @block = block

        read_data do |chunk|
          advance_native(chunk)
        end

        # Add any missing closing tags
        if !strict? and !@elements.empty?
          @elements.length.times { on_element_end }
        end
      ensure
        @block = nil
      end

      # @return [TrueClass|FalseClass]
      def html?
        @html == true
      end

      # @return [TrueClass|FalseClass]
      def strict?
        @strict
      end

      # @return [TrueClass|FalseClass]
      def html_script?
        html? && current_element == HTML_SCRIPT
      end

      # @return [TrueClass|FalseClass]
      def html_style?
        html? && current_element == HTML_STYLE
      end

      private

      # @param [Fixnum] amount The amount of lines to advance.
      def advance_line(amount = 1)
        @line += amount
      end

      # Calls the supplied block with the information of the current token.
      #
      # @param [Symbol] type The token type.
      # @param [String] value The token value.
      #
      # @yieldparam [String] type
      # @yieldparam [String] value
      # @yieldparam [Fixnum] line
      def add_token(type, value = nil)
        @block.call(type, value, @line)
      end

      # Returns the name of the element we're currently in.
      #
      # @return [String]
      def current_element
        @elements.last
      end

      # Called when processing a single quote.
      def on_string_squote
        add_token(:T_STRING_SQUOTE)
      end

      # Called when processing a double quote.
      def on_string_dquote
        add_token(:T_STRING_DQUOTE)
      end

      # Called when processing the body of a string.
      #
      # @param [String] value The data between the quotes.
      def on_string_body(value)
        add_token(:T_STRING_BODY, value)
      end

      # Called when a doctype starts.
      def on_doctype_start
        add_token(:T_DOCTYPE_START)
      end

      # Called on the identifier specifying the type of the doctype.
      #
      # @param [String] value
      def on_doctype_type(value)
        add_token(:T_DOCTYPE_TYPE, value)
      end

      # Called on the identifier specifying the name of the doctype.
      #
      # @param [String] value
      def on_doctype_name(value)
        add_token(:T_DOCTYPE_NAME, value)
      end

      # Called on the end of a doctype.
      def on_doctype_end
        add_token(:T_DOCTYPE_END)
      end

      # Called on an inline doctype block.
      #
      # @param [String] value
      def on_doctype_inline(value)
        add_token(:T_DOCTYPE_INLINE, value)
      end

      # Called on the open CDATA tag.
      def on_cdata_start
        add_token(:T_CDATA_START)
      end

      # Called on the closing CDATA tag.
      def on_cdata_end
        add_token(:T_CDATA_END)
      end

      # Called for the body of a CDATA tag.
      #
      # @param [String] value
      def on_cdata_body(value)
        add_token(:T_CDATA_BODY, value)
      end

      # Called on the open comment tag.
      def on_comment_start
        add_token(:T_COMMENT_START)
      end

      # Called on the closing comment tag.
      def on_comment_end
        add_token(:T_COMMENT_END)
      end

      # Called on a comment.
      #
      # @param [String] value
      def on_comment_body(value)
        add_token(:T_COMMENT_BODY, value)
      end

      # Called on the start of an XML declaration tag.
      def on_xml_decl_start
        add_token(:T_XML_DECL_START)
      end

      # Called on the end of an XML declaration tag.
      def on_xml_decl_end
        add_token(:T_XML_DECL_END)
      end

      # Called on the start of a processing instruction.
      def on_proc_ins_start
        add_token(:T_PROC_INS_START)
      end

      # Called on a processing instruction name.
      #
      # @param [String] value
      def on_proc_ins_name(value)
        add_token(:T_PROC_INS_NAME, value)
      end

      # Called on the body of a processing instruction.
      #
      # @param [String] value
      def on_proc_ins_body(value)
        add_token(:T_PROC_INS_BODY, value)
      end

      # Called on the end of a processing instruction.
      def on_proc_ins_end
        add_token(:T_PROC_INS_END)
      end

      # Called on the name of an element.
      #
      # @param [String] name The name of the element, including namespace.
      def on_element_name(name)
        before_html_element_name(name) if html?

        add_element(name)
      end

      # Handles inserting of any missing tags whenever a new HTML tag is opened.
      #
      # @param [String] name
      def before_html_element_name(name)
        close_current = HTML_CLOSE_SELF[current_element]

        if close_current and !close_current.allow?(name)
          on_element_end
        end

        # Close remaining parent elements. This for example ensures that a
        # "<tbody>" not only closes an unclosed "<th>" but also the surrounding,
        # unclosed "<tr>".
        while close_current = HTML_CLOSE_SELF[current_element]
          if close_current.allow?(name)
            break
          else
            on_element_end
          end
        end
      end

      # @param [String] name
      def add_element(name)
        @elements << name

        add_token(:T_ELEM_NAME, name)
      end

      # Called on the element namespace.
      #
      # @param [String] namespace
      def on_element_ns(namespace)
        add_token(:T_ELEM_NS, namespace)
      end

      # Called on the closing `>` of the open tag of an element.
      def on_element_open_end
        return unless html?

        # Only downcase the name if we can't find an all lower/upper version of
        # the element name. This can save us a *lot* of String allocations.
        if HTML_VOID_ELEMENTS.allow?(current_element) \
        or HTML_VOID_ELEMENTS.allow?(current_element.downcase)
          add_token(:T_ELEM_END)
          @elements.pop
        end
      end

      # Called on the closing tag of an element.
      #
      # @param [String] name The name of the element (minus namespace
      #  prefix). This is not set for self closing tags.
      def on_element_end(name = nil)
        return if @elements.empty?

        if html? and name and @elements.include?(name)
          while current_element != name
            add_token(:T_ELEM_END)
            @elements.pop
          end
        end

        # Prevents a superfluous end tag of a self-closing HTML tag from
        # closing its parent element prematurely
        return if html? && name && name != current_element

        add_token(:T_ELEM_END)
        @elements.pop
      end

      # Called on regular text values.
      #
      # @param [String] value
      def on_text(value)
        return if value.empty?

        add_token(:T_TEXT, value)
      end

      # Called on attribute namespaces.
      #
      # @param [String] value
      def on_attribute_ns(value)
        add_token(:T_ATTR_NS, value)
      end

      # Called on tag attributes.
      #
      # @param [String] value
      def on_attribute(value)
        add_token(:T_ATTR, value)
      end
    end # Lexer
  end # XML
end # Oga
