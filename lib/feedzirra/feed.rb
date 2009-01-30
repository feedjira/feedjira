require 'feedzirra/atom'
require 'feedzirra/atom_feed_burner'
require 'curb'
require 'activesupport'

module Feedzirra
  class Feed
    USER_AGENT = "feedzirra http://github.com/pauldix/feedzirra/tree/master"
    
    def self.parse(xml)
      determine_feed_parser_for_xml(xml).parse(xml)
    end

    def self.determine_feed_parser_for_xml(xml)
      start_of_doc = xml.slice(0, 500)
      feed_classes.detect {|klass| klass.able_to_parse?(start_of_doc)}
    end

    def self.add_feed_class(klass)
      feed_classes.unshift klass
    end
    
    def self.feed_classes
      @feed_classes ||= [RSS, RDF, AtomFeedBurner, Atom]
    end

    # can take a single url or an array of urls
    # when passed a single url it returns the body of the response
    # when passed an array of urls it returns a hash with the urls as keys and body of responses as values
    def self.fetch_raw(urls, options = {})
      urls = [*urls]
      multi = Curl::Multi.new
      responses = {}
      urls.each do |url|
        easy = Curl::Easy.new(url) do |curl|
          curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
          curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
          curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)
          curl.follow_location = true
          curl.on_success do |c|
            responses[url] = c.body_str
          end
          curl.on_failure do |c|
            responses[url] = c.response_code
          end
        end
        multi.add(easy)
      end

      multi.perform
      return responses.size == 1 ? responses.values.first : responses
    end
    
    def self.fetch_and_parse(urls, options = {})
      urls = [*urls]
      multi = Curl::Multi.new
      responses = {}
      urls.each do |url|
        easy = Curl::Easy.new(url) do |curl|
          curl.headers["User-Agent"]        = (options[:user_agent] || USER_AGENT)
          curl.headers["If-Modified-Since"] = options[:if_modified_since].httpdate if options.has_key?(:if_modified_since)
          curl.headers["If-None-Match"]     = options[:if_none_match] if options.has_key?(:if_none_match)
          curl.follow_location = true
          curl.on_success do |c|
            feed = Feed.parse(c.body_str)
            feed.feed_url ||= c.last_effective_url
            responses[url] = feed
            options[:on_success].call(url, feed) if options.has_key?(:on_success)
          end
          curl.on_failure do |c|
            responses[url] = c.response_code
            options[:on_failure].call(url, c.response_code, c.header_str, c.body_str) if options.has_key?(:on_failure)
          end
        end
        multi.add(easy)
      end

      multi.perform
      return responses.size == 1 ? responses.values.first : responses
    end
    
    def self.etag_from_header(header)
      header =~ /.*ETag:\s(.*)\r/
      $1
    end
    
    def self.last_modified_from_header(header)
      header =~ /.*Last-Modified:\s(.*)\r/
      $1
    end
  end
end