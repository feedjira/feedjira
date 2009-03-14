module Feedzirra
  class NoParserAvailable < StandardError; end
  
  class Feed
    USER_AGENT = "feedzirra http://github.com/pauldix/feedzirra/tree/master"
    
    def self.parse(xml)
      if parser = determine_feed_parser_for_xml(xml)
        parser.parse(xml)
      else
        raise NoParserAvailable.new("no valid parser for content.")
      end
    end

    def self.determine_feed_parser_for_xml(xml)
      start_of_doc = xml.slice(0, 1000)
      feed_classes.detect {|klass| klass.able_to_parse?(start_of_doc)}
    end

    def self.add_feed_class(klass)
      feed_classes.unshift klass
    end
    
    def self.feed_classes
      @feed_classes ||= [ITunesRSS, RSS, AtomFeedBurner, Atom]
    end

    # can take a single url or an array of urls
    # when passed a single url it returns the body of the response
    # when passed an array of urls it returns a hash with the urls as keys and body of responses as values
    def self.fetch_raw(urls, options = {})
      url_queue = [*urls]
      multi = Curl::Multi.new
      responses = {}
      url_queue.each do |url|
        easy = Curl::Easy.new(url) do |curl|
          curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
          curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
          curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)
          curl.headers["Accept-encoding"]   = 'gzip, deflate'
          curl.follow_location = true
          curl.on_success do |c|
            responses[url] = decode_content(c)
          end
          curl.on_failure do |c|
            responses[url] = c.response_code
          end
        end
        multi.add(easy)
      end

      multi.perform
      return urls.is_a?(String) ? responses.values.first : responses
    end
    
    def self.fetch_and_parse(urls, options = {})
      url_queue = [*urls]
      multi = Curl::Multi.new

      # I broke these down so I would only try to do 30 simultaneously because 
      # I was getting weird errors when doing a lot. As one finishes it pops another off the queue.
      responses = {}
      url_queue.slice!(0, 30).each do |url|
        add_url_to_multi(multi, url, url_queue, responses, options)
      end

      multi.perform
      return urls.is_a?(String) ? responses.values.first : responses
    end
    
    def self.decode_content(c)
      if c.header_str.match(/Content-Encoding: gzip/)
        gz =  Zlib::GzipReader.new(StringIO.new(c.body_str))
        xml = gz.read
        gz.close
      elsif c.header_str.match(/Content-Encoding: deflate/)
        xml = Zlib::Deflate.inflate(c.body_str)
      else
        xml = c.body_str
      end
      
      xml
    end
    
    def self.update(feeds, options = {})
      feed_queue = [*feeds]
      multi = Curl::Multi.new
      responses = {}
      feed_queue.slice!(0, 30).each do |feed|
        add_feed_to_multi(multi, feed, feed_queue, responses, options)
      end
    
      multi.perform
      return responses.size == 1 ? responses.values.first : responses.values
    end
    
    def self.add_url_to_multi(multi, url, url_queue, responses, options)
      easy = Curl::Easy.new(url) do |curl|
        curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
        curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
        curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)
        curl.headers["Accept-encoding"]   = 'gzip, deflate'
        curl.follow_location = true
        curl.on_success do |c|
          add_url_to_multi(multi, url_queue.shift, url_queue, responses, options) unless url_queue.empty?
          xml = decode_content(c)
          klass = determine_feed_parser_for_xml(xml)
          if klass
            feed = klass.parse(xml)
            feed.feed_url = c.last_effective_url
            feed.etag = etag_from_header(c.header_str)
            feed.last_modified = last_modified_from_header(c.header_str)
            responses[url] = feed
            options[:on_success].call(url, feed) if options.has_key?(:on_success)
          else
            puts "Error determining parser for #{url} - #{c.last_effective_url}"
          end
        end
        curl.on_failure do |c|
          add_url_to_multi(multi, url_queue.shift, url_queue, responses, options) unless url_queue.empty?
          responses[url] = c.response_code
          options[:on_failure].call(url, c.response_code, c.header_str, c.body_str) if options.has_key?(:on_failure)
        end
      end
      multi.add(easy)
    end
    
    def self.add_feed_to_multi(multi, feed, feed_queue, responses, options)
      # on_success = options[:on_success]
      # on_failure = options[:on_failure]
      # options[:on_success] = lambda do ||
      
      easy = Curl::Easy.new(feed.feed_url) do |curl|
        curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
        curl.headers["If-Modified-Since"] = feed.last_modified.httpdate if feed.last_modified
        curl.headers["If-None-Match"]     = feed.etag if feed.etag
        curl.follow_location = true
        curl.on_success do |c|
          add_feed_to_multi(multi, feed_queue.shift, feed_queue, responses, options) unless feed_queue.empty?
          updated_feed = Feed.parse(c.body_str)
          updated_feed.feed_url = c.last_effective_url
          updated_feed.etag = etag_from_header(c.header_str)
          updated_feed.last_modified = last_modified_from_header(c.header_str)
          feed.update_from_feed(updated_feed)
          responses[feed.feed_url] = feed
          options[:on_success].call(feed) if options.has_key?(:on_success)
        end
        curl.on_failure do |c|
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
    
    def self.etag_from_header(header)
      header =~ /.*ETag:\s(.*)\r/
      $1
    end
    
    def self.last_modified_from_header(header)
      header =~ /.*Last-Modified:\s(.*)\r/
      Time.parse($1) if $1
    end
  end
end