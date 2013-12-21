module Feedzirra
  class Feed
    USER_AGENT = "feedzirra http://github.com/pauldix/feedzirra/tree/master"

    # Passes raw XML and callbacks to a parser.
    # === Parameters
    # [parser<Object>] The parser to pass arguments to - must respond to
    # `parse` and should return a Feed object.
    # [xml<String>] The XML that you would like parsed.
    # === Returns
    # An instance of the parser feed type.
    def self.parse_with(parser, xml, &block)
      parser.parse xml, &block
    end

    # Takes a raw XML feed and attempts to parse it. If no parser is available a Feedzirra::NoParserAvailable exception is raised.
    # You can pass a block to be called when there's an error during the parsing.
    # === Parameters
    # [xml<String>] The XML that you would like parsed.
    # === Returns
    # An instance of the determined feed type. By default, one of these:
    # * Feedzirra::Parser::RSSFeedBurner
    # * Feedzirra::Parser::GoogleDocsAtom
    # * Feedzirra::Parser::AtomFeedBurner
    # * Feedzirra::Parser::Atom
    # * Feedzirra::Parser::ITunesRSS
    # * Feedzirra::Parser::RSS
    # === Raises
    # Feedzirra::NoParserAvailable : If no valid parser classes could be found for the feed.
    def self.parse(xml, &block)
      if parser = determine_feed_parser_for_xml(xml)
        parse_with parser, xml, &block
      else
        raise NoParserAvailable.new("No valid parser for XML.")
      end
    end

    # Determines the correct parser class to use for parsing the feed.
    #
    # === Parameters
    # [xml<String>] The XML that you would like determine the parser for.
    # === Returns
    # The class name of the parser that can handle the XML.
    def self.determine_feed_parser_for_xml(xml)
      start_of_doc = xml.slice(0, 2000)
      feed_classes.detect {|klass| klass.able_to_parse?(start_of_doc)}
    end

    # Adds a new feed parsing class that will be used for parsing.
    #
    # === Parameters
    # [klass<Constant>] The class/constant that you want to register.
    # === Returns
    # A updated array of feed parser class names.
    def self.add_feed_class(klass)
      feed_classes.unshift klass
    end

    # Provides a list of registered feed parsing classes.
    #
    # === Returns
    # A array of class names.
    def self.feed_classes
      @feed_classes ||= [
        Feedzirra::Parser::RSSFeedBurner,
        Feedzirra::Parser::GoogleDocsAtom,
        Feedzirra::Parser::AtomFeedBurner,
        Feedzirra::Parser::Atom,
        Feedzirra::Parser::ITunesRSS,
        Feedzirra::Parser::RSS
      ]
    end

    # Makes all registered feeds types look for the passed in element to parse.
    # This is actually just a call to element (a SAXMachine call) in the class.
    #
    # === Parameters
    # [element_tag<String>] The element tag
    # [options<Hash>] Valid keys are same as with SAXMachine
    def self.add_common_feed_element(element_tag, options = {})
      feed_classes.each do |k|
        k.element element_tag, options
      end
    end

    # Makes all registered feeds types look for the passed in elements to parse.
    # This is actually just a call to elements (a SAXMachine call) in the class.
    #
    # === Parameters
    # [element_tag<String>] The element tag
    # [options<Hash>] Valid keys are same as with SAXMachine
    def self.add_common_feed_elements(element_tag, options = {})
      feed_classes.each do |k|
        k.elements element_tag, options
      end
    end

    # Makes all registered entry types look for the passed in element to parse.
    # This is actually just a call to element (a SAXMachine call) in the class.
    #
    # === Parameters
    # [element_tag<String>]
    # [options<Hash>] Valid keys are same as with SAXMachine
    def self.add_common_feed_entry_element(element_tag, options = {})
      call_on_each_feed_entry :element, element_tag, options
    end

    # Makes all registered entry types look for the passed in elements to parse.
    # This is actually just a call to element (a SAXMachine call) in the class.
    #
    # === Parameters
    # [element_tag<String>]
    # [options<Hash>] Valid keys are same as with SAXMachine
    def self.add_common_feed_entry_elements(element_tag, options = {})
      call_on_each_feed_entry :elements, element_tag, options
    end

    # Call a method on all feed entries classes.
    #
    # === Parameters
    # [method<Symbol>] The method name
    # [parameters<Array>] The method parameters
    def self.call_on_each_feed_entry(method, *parameters)
      feed_classes.each do |k|
        # iterate on the collections defined in the sax collection
        k.sax_config.collection_elements.each_value do |vl|
          # vl is a list of CollectionConfig mapped to an attribute name
          # we'll look for the one set as 'entries' and add the new element
          vl.find_all{|v| (v.accessor == 'entries') && (v.data_class.class == Class)}.each do |v|
              v.data_class.send(method, *parameters)
          end
        end
      end
    end

    # Setup curl from options.
    # Possible parameters:
    # * :user_agent          - overrides the default user agent.
    # * :compress            - any value to enable compression
    # * :enable_cookies      - boolean
    # * :cookiefile          - file to read cookies
    # * :cookies             - contents of cookies header
    # * :http_authentication - array containing username, then password
    # * :proxy_url           - proxy url
    # * :proxy_port          - proxy port
    # * :max_redirects       - max number of redirections
    # * :timeout             - timeout
    # * :ssl_verify_host     - boolean
    # * :ssl_verify_peer     - boolean
    # * :ssl_version         - the ssl version to use, see OpenSSL::SSL::SSLContext::METHODS for options
    def self.setup_easy(curl, options={})
      curl.headers["Accept-encoding"]   = 'gzip, deflate' if options.has_key?(:compress)
      curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
      curl.enable_cookies               = options[:enable_cookies] if options.has_key?(:enable_cookies)
      curl.cookiefile                   = options[:cookiefile] if options.has_key?(:cookiefile)
      curl.cookies                      = options[:cookies] if options.has_key?(:cookies)

      curl.userpwd = options[:http_authentication].join(':') if options.has_key?(:http_authentication)
      curl.proxy_url = options[:proxy_url] if options.has_key?(:proxy_url)
      curl.proxy_port = options[:proxy_port] if options.has_key?(:proxy_port)
      curl.max_redirects = options[:max_redirects] if options[:max_redirects]
      curl.timeout = options[:timeout] if options[:timeout]
      curl.ssl_verify_host = options[:ssl_verify_host] if options.has_key?(:ssl_verify_host)
      curl.ssl_verify_peer = options[:ssl_verify_peer] if options.has_key?(:ssl_verify_peer)
      curl.ssl_version = options[:ssl_version] if options.has_key?(:ssl_version)

      curl.follow_location = true
    end

    # Fetches and returns the raw XML for each URL provided.
    #
    # === Parameters
    # [urls<String> or <Array>] A single feed URL, or an array of feed URLs.
    # [options<Hash>] Valid keys for this argument as as followed:
    #                 :if_modified_since - Time object representing when the feed was last updated.
    #                 :if_none_match - String that's normally an etag for the request that was stored previously.
    #                 :on_success - Block that gets executed after a successful request.
    #                 :on_failure - Block that gets executed after a failed request.
    #                 * all parameters defined in setup_easy
    # === Returns
    # A String of XML if a single URL is passed.
    #
    # A Hash if multiple URL's are passed. The key will be the URL, and the value the XML.
    def self.fetch_raw(urls, options = {})
      url_queue = [*urls]
      multi = Curl::Multi.new
      responses = {}
      url_queue.each do |url|
        easy = Curl::Easy.new(url) do |curl|
          setup_easy curl, options

          curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
          curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)

          curl.on_success do |c|
            responses[url] = decode_content(c)
          end

          curl.on_complete do |c, err|
            responses[url] = c.response_code unless responses.has_key?(url)
          end
        end
        multi.add(easy)
      end

      multi.perform
      urls.is_a?(String) ? responses.values.first : responses
    end

    # Fetches and returns the parsed XML for each URL provided.
    #
    # === Parameters
    # [urls<String> or <Array>] A single feed URL, or an array of feed URLs.
    # [options<Hash>] Valid keys for this argument as as followed:
    # * :user_agent - String that overrides the default user agent.
    # * :if_modified_since - Time object representing when the feed was last updated.
    # * :if_none_match - String, an etag for the request that was stored previously.
    # * :on_success - Block that gets executed after a successful request.
    # * :on_failure - Block that gets executed after a failed request.
    # === Returns
    # A Feed object if a single URL is passed.
    #
    # A Hash if multiple URL's are passed. The key will be the URL, and the value the Feed object.
    def self.fetch_and_parse(urls, options = {})
      url_queue = [*urls]
      multi = Curl::Multi.new
      responses = {}

      # I broke these down so I would only try to do 30 simultaneously because
      # I was getting weird errors when doing a lot. As one finishes it pops another off the queue.
      url_queue.slice!(0, 30).each do |url|
        add_url_to_multi(multi, url, url_queue, responses, options)
      end

      multi.perform
      return urls.is_a?(String) ? responses.values.first : responses
    end

    # Decodes the XML document if it was compressed.
    #
    # === Parameters
    # [curl_request<Curl::Easy>] The Curl::Easy response object from the request.
    # === Returns
    # A decoded string of XML.
    def self.decode_content(c)
      if c.header_str.match(/Content-Encoding: gzip/i)
        begin
          gz =  Zlib::GzipReader.new(StringIO.new(c.body_str))
          xml = gz.read
          gz.close
        rescue Zlib::GzipFile::Error
          # Maybe this is not gzipped?
          xml = c.body_str
        end
      elsif c.header_str.match(/Content-Encoding: deflate/i)
        xml = Zlib::Inflate.inflate(c.body_str)
      else
        xml = c.body_str
      end

      xml
    end

    # Updates each feed for each Feed object provided.
    #
    # === Parameters
    # [feeds<Feed> or <Array>] A single feed object, or an array of feed objects.
    # [options<Hash>] Valid keys for this argument as as followed:
    #                 * :on_success - Block that gets executed after a successful request.
    #                 * :on_failure - Block that gets executed after a failed request.
    #                 * all parameters defined in setup_easy
    # === Returns
    # A updated Feed object if a single URL is passed.
    #
    # A Hash if multiple Feeds are passed. The key will be the URL, and the value the updated Feed object.
    def self.update(feeds, options = {})
      feed_queue = [*feeds]
      multi = Curl::Multi.new
      responses = {}

      feed_queue.slice!(0, 30).each do |feed|
        add_feed_to_multi(multi, feed, feed_queue, responses, options)
      end

      multi.perform
      feeds.is_a?(Array) ? responses : responses.values.first
    end

    # An abstraction for adding a feed by URL to the passed Curb::multi stack.
    #
    # === Parameters
    # [multi<Curl::Multi>] The Curl::Multi object that the request should be added too.
    # [url<String>] The URL of the feed that you would like to be fetched.
    # [url_queue<Array>] An array of URLs that are queued for request.
    # [responses<Hash>] Existing responses that you want the response from the request added to.
    # [feeds<String> or <Array>] A single feed object, or an array of feed objects.
    # [options<Hash>] Valid keys for this argument as as followed:
    #                 * :on_success - Block that gets executed after a successful request.
    #                 * :on_failure - Block that gets executed after a failed request.
    #                 * all parameters defined in setup_easy
    # === Returns
    # The updated Curl::Multi object with the request details added to it's stack.
    def self.add_url_to_multi(multi, url, url_queue, responses, options)
      easy = Curl::Easy.new(url) do |curl|
        setup_easy curl, options
        curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
        curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)

        curl.on_success do |c|
          xml = decode_content(c)
          klass = determine_feed_parser_for_xml(xml)

          if klass
            begin
              feed = parse_with klass, xml, &on_parser_failure(url)

              feed.feed_url = c.last_effective_url
              feed.etag = etag_from_header(c.header_str)
              feed.last_modified = last_modified_from_header(c.header_str)
              responses[url] = feed
              options[:on_success].call(url, feed) if options.has_key?(:on_success)
            rescue Exception => e
              call_on_failure(url, c, e, options[:on_failure])
            end
          else
            call_on_failure(url, c, "Can't determine a parser", options[:on_failure])
          end
        end

        #
        # trigger on_failure for 404s
        #
        curl.on_complete do |c|
          add_url_to_multi(multi, url_queue.shift, url_queue, responses, options) unless url_queue.empty?
          responses[url] = c.response_code unless responses.has_key?(url)
        end

        curl.on_redirect do |c|
          if c.response_code == 304 # it's not modified. this isn't an error condition
            options[:on_success].call(url, nil) if options.has_key?(:on_success)
          end
        end

        curl.on_missing do |c|
          if c.response_code == 404 && options.has_key?(:on_failure)
            call_on_failure(url, c, 'Server returned a 404', options[:on_failure])
          end
        end

        curl.on_failure do |c, err|
          responses[url] = c.response_code
          call_on_failure(url, c, err, options[:on_failure])
        end
      end
      multi.add(easy)
    end

    # An abstraction for adding a feed by a Feed object to the passed Curb::multi stack.
    #
    # === Parameters
    # [multi<Curl::Multi>] The Curl::Multi object that the request should be added too.
    # [feed<Feed>] A feed object that you would like to be fetched.
    # [url_queue<Array>] An array of feed objects that are queued for request.
    # [responses<Hash>] Existing responses that you want the response from the request added to.
    # [feeds<String>] or <Array> A single feed object, or an array of feed objects.
    # [options<Hash>] Valid keys for this argument as as followed:
    #                 * :on_success - Block that gets executed after a successful request.
    #                 * :on_failure - Block that gets executed after a failed request.
    #                 * all parameters defined in setup_easy
    # === Returns
    # The updated Curl::Multi object with the request details added to it's stack.
    def self.add_feed_to_multi(multi, feed, feed_queue, responses, options)
      easy = Curl::Easy.new(feed.feed_url) do |curl|
        setup_easy curl, options
        curl.headers["If-Modified-Since"] = feed.last_modified.httpdate if feed.last_modified
        curl.headers["If-Modified-Since"] = options[:if_modified_since] if options[:if_modified_since] && (!feed.last_modified || (Time.parse(options[:if_modified_since].to_s) > feed.last_modified))
        curl.headers["If-None-Match"]     = feed.etag if feed.etag

        curl.on_success do |c|
          begin
            updated_feed = Feed.parse c.body_str, &on_parser_failure(feed.feed_url)

            updated_feed.feed_url = c.last_effective_url
            updated_feed.etag = etag_from_header(c.header_str)
            updated_feed.last_modified = last_modified_from_header(c.header_str)
            feed.update_from_feed(updated_feed)
            responses[feed.feed_url] = feed
            options[:on_success].call(feed) if options.has_key?(:on_success)
          rescue Exception => e
            call_on_failure(feed.feed_url, c, e, options[:on_failure])
          end
        end

        curl.on_failure do |c, err| # response code 50X
          responses[feed.feed_url] = c.response_code
          call_on_failure(feed.feed_url, c, 'Server returned a 404', options[:on_failure])
        end

        curl.on_redirect do |c, err| # response code 30X
          if c.response_code == 304
            options[:on_success].call(feed) if options.has_key?(:on_success)
          else
            responses[feed.feed_url] = c.response_code
            call_on_failure(feed.feed_url, c, err, options[:on_failure])
          end
        end

        curl.on_complete do |c|
          add_feed_to_multi(multi, feed_queue.shift, feed_queue, responses, options) unless feed_queue.empty?
          responses[feed.feed_url] = feed unless responses.has_key?(feed.feed_url)
        end
      end
      multi.add(easy)
    end

    # Determines the etag from the request headers.
    #
    # === Parameters
    # [header<String>] Raw request header returned from the request
    # === Returns
    # A string of the etag or nil if it cannot be found in the headers.
    def self.etag_from_header(header)
      header =~ /.*ETag:\s(.*)\r/
      $1
    end

    # Determines the last modified date from the request headers.
    #
    # === Parameters
    # [header<String>] Raw request header returned from the request
    # === Returns
    # A Time object of the last modified date or nil if it cannot be found in the headers.
    def self.last_modified_from_header(header)
      header =~ /.*Last-Modified:\s(.*)\r/
      Time.parse_safely($1) if $1
    end

    class << self
      private

      def on_parser_failure(url)
        Proc.new { |message| raise "Error while parsing [#{url}] #{message}" }
      end

      def call_on_failure(url, c, error, on_failure)
        if on_failure
          if on_failure.arity == 5
            on_failure.call(url, c.response_code, c.header_str, c.body_str, error)
          elsif on_failure.arity == 4
            warn 'on_failure proc with deprecated arity 4 should include a fifth parameter containing the error'
            on_failure.call(url, c.response_code, c.header_str, c.body_str)
          else
            warn "on_failure proc with invalid parameters number #{on_failure.arity} instead of 5, ignoring it"
          end
        end
      end
    end
  end
end
