require 'feedzirra/atom'
require 'feedzirra/atom_feed_burner'
require 'curb'

module Feedzirra
  class Feed
    def self.parse(xml)
      determine_feed_parser_for_xml(xml).parse(xml)
    end

    def self.determine_feed_parser_for_xml(xml)
      start_of_doc = xml.slice(0, 500)
      feed_classes.detect {|klass| klass.able_to_parse?(start_of_doc)}
    end

    def self.add_feed_class(klass)
      feed_classes << klass
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
          curl.headers["User-Agent"] = "feedzirra"
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