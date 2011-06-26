module Feedzirra
  class NoParserAvailable < StandardError; end
  
  class Feed
    USER_AGENT = "feedzirra http://github.com/pauldix/feedzirra/tree/master"
    
    # Takes a raw XML feed and attempts to parse it. If no parser is available a Feedzirra::NoParserAvailable exception is raised.
    #
    # === Parameters
    # [xml<String>] The XML that you would like parsed.
    # === Returns
    # An instance of the determined feed type. By default a Feedzirra::Atom, Feedzirra::AtomFeedBurner, Feedzirra::RDF, or Feedzirra::RSS object.
    # === Raises
    # Feedzirra::NoParserAvailable : If no valid parser classes could be found for the feed.
    def self.parse(xml)
      if parser = determine_feed_parser_for_xml(xml)
        parser.parse(xml)
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
      @feed_classes ||= [Feedzirra::Parser::AtomFeedBurner, Feedzirra::Parser::RSS, Feedzirra::Parser::Atom]
    end
    
    # Makes all entry types look for the passed in element to parse. This is actually just a call to 
    # element (a SAXMachine call) in the class
    #
    # === Parameters
    # [element_tag<String>]
    # [options<Hash>] Valid keys are same as with SAXMachine
    def self.add_common_feed_entry_element(element_tag, options = {})
      # need to think of a better way to do this. will break for people who want this behavior
      # across their added classes
      feed_classes.map{|k| eval("#{k}Entry") }.each do |klass|
        klass.send(:element, element_tag, options)
      end
    end
    
    # Fetches and returns the raw XML for each URL provided.
    #
    # === Parameters
    # [urls<String> or <Array>] A single feed URL, or an array of feed URLs.
    # [options<Hash>] Valid keys for this argument as as followed:
    #                 :user_agent - String that overrides the default user agent.
    #                 :if_modified_since - Time object representing when the feed was last updated.
    #                 :if_none_match - String that's normally an etag for the request that was stored previously.
    #                 :on_success - Block that gets executed after a successful request.
    #                 :on_failure - Block that gets executed after a failed request.
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
          curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
          curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
          curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)
          curl.headers["Accept-encoding"]   = 'gzip, deflate' if options.has_key?(:compress)
          curl.follow_location = true
          curl.userpwd = options[:http_authentication].join(':') if options.has_key?(:http_authentication)
          
          curl.max_redirects = options[:max_redirects] if options[:max_redirects]
          curl.timeout = options[:timeout] if options[:timeout]

          curl.on_success do |c|
            responses[url] = decode_content(c)
          end
          curl.on_failure do |c, err|
            responses[url] = c.response_code
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
      if c.header_str.match(/Content-Encoding: gzip/)
        begin
          gz =  Zlib::GzipReader.new(StringIO.new(c.body_str))
          xml = gz.read
          gz.close
        rescue Zlib::GzipFile::Error 
          # Maybe this is not gzipped?
          xml = c.body_str
        end
      elsif c.header_str.match(/Content-Encoding: deflate/)
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
    #                 * :user_agent - String that overrides the default user agent.
    #                 * :on_success - Block that gets executed after a successful request.
    #                 * :on_failure - Block that gets executed after a failed request.
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
      responses.size == 1 ? responses.values.first : responses.values
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
    #                 * :user_agent - String that overrides the default user agent.
    #                 * :on_success - Block that gets executed after a successful request.
    #                 * :on_failure - Block that gets executed after a failed request.
    # === Returns
    # The updated Curl::Multi object with the request details added to it's stack.
    def self.add_url_to_multi(multi, url, url_queue, responses, options)
      easy = Curl::Easy.new(url) do |curl|
        curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
        curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
        curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)
        curl.headers["Accept-encoding"]   = 'gzip, deflate' if options.has_key?(:compress)
        curl.follow_location = true
        curl.userpwd = options[:http_authentication].join(':') if options.has_key?(:http_authentication)

        curl.max_redirects = options[:max_redirects] if options[:max_redirects]
        curl.timeout = options[:timeout] if options[:timeout]
        
        curl.on_success do |c|
          add_url_to_multi(multi, url_queue.shift, url_queue, responses, options) unless url_queue.empty?
          xml = decode_content(c)
          klass = determine_feed_parser_for_xml(xml)
          
          if klass
            begin
              feed = klass.parse(xml)
              feed.feed_url = c.last_effective_url
              feed.etag = etag_from_header(c.header_str)
              feed.last_modified = last_modified_from_header(c.header_str)
              responses[url] = feed
              options[:on_success].call(url, feed) if options.has_key?(:on_success)
            rescue Exception => e
              options[:on_failure].call(url, c.response_code, c.header_str, c.body_str) if options.has_key?(:on_failure)
            end
          else
            # puts "Error determining parser for #{url} - #{c.last_effective_url}"
            # raise NoParserAvailable.new("no valid parser for content.") (this would unfirtunately fail the whole 'multi', so it's not really useable)
            options[:on_failure].call(url, c.response_code, c.header_str, c.body_str) if options.has_key?(:on_failure)
          end
        end
        
        curl.on_failure do |c, err|
          add_url_to_multi(multi, url_queue.shift, url_queue, responses, options) unless url_queue.empty?
          responses[url] = c.response_code
          options[:on_failure].call(url, c.response_code, c.header_str, c.body_str) if options.has_key?(:on_failure)
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
    #                 * :user_agent - String that overrides the default user agent.
    #                 * :on_success - Block that gets executed after a successful request.
    #                 * :on_failure - Block that gets executed after a failed request.
    # === Returns
    # The updated Curl::Multi object with the request details added to it's stack.
    def self.add_feed_to_multi(multi, feed, feed_queue, responses, options) 
      easy = Curl::Easy.new(feed.feed_url) do |curl|
        curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
        curl.headers["If-Modified-Since"] = feed.last_modified.httpdate if feed.last_modified
        curl.headers["If-None-Match"]     = feed.etag if feed.etag
        curl.userpwd = options[:http_authentication].join(':') if options.has_key?(:http_authentication)
        curl.follow_location = true

        curl.max_redirects = options[:max_redirects] if options[:max_redirects]
        curl.timeout = options[:timeout] if options[:timeout]

        curl.on_success do |c|
          begin
            add_feed_to_multi(multi, feed_queue.shift, feed_queue, responses, options) unless feed_queue.empty?
            updated_feed = Feed.parse(c.body_str)
            updated_feed.feed_url = c.last_effective_url
            updated_feed.etag = etag_from_header(c.header_str)
            updated_feed.last_modified = last_modified_from_header(c.header_str)
            feed.update_from_feed(updated_feed)
            responses[feed.feed_url] = feed
            options[:on_success].call(feed) if options.has_key?(:on_success)
          rescue Exception => e
            options[:on_failure].call(feed, c.response_code, c.header_str, c.body_str) if options.has_key?(:on_failure)
          end
        end

        curl.on_failure do |c, err|
          add_feed_to_multi(multi, feed_queue.shift, feed_queue, responses, options) unless feed_queue.empty?
          response_code = c.response_code
          if response_code == 304 # it's not modified. this isn't an error condition
            responses[feed.feed_url] = feed
            options[:on_success].call(feed) if options.has_key?(:on_success)
          else
            responses[feed.url] = c.response_code
            options[:on_failure].call(feed, c.response_code, c.header_str, c.body_str) if options.has_key?(:on_failure)
          end
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
      Time.parse($1) if $1
    end
  end
end
