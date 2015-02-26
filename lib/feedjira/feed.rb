module Feedjira
  class Feed
    def self.parse_with(parser, xml, &block)
      parser.parse xml, &block
    end

    def self.parse(xml, &block)
      if parser = determine_feed_parser_for_xml(xml)
        parse_with parser, xml, &block
      else
        raise NoParserAvailable.new("No valid parser for XML.")
      end
    end

    def self.determine_feed_parser_for_xml(xml)
      start_of_doc = xml.slice(0, 2000)
      feed_classes.detect {|klass| klass.able_to_parse?(start_of_doc)}
    end

    def self.add_feed_class(klass)
      feed_classes.unshift klass
    end

    def self.feed_classes
      @feed_classes ||= [
        Feedjira::Parser::RSSFeedBurner,
        Feedjira::Parser::GoogleDocsAtom,
        Feedjira::Parser::AtomFeedBurner,
        Feedjira::Parser::Atom,
        Feedjira::Parser::ITunesRSS,
        Feedjira::Parser::RSS
      ]
    end

    def self.add_common_feed_element(element_tag, options = {})
      feed_classes.each do |k|
        k.element element_tag, options
      end
    end

    def self.add_common_feed_elements(element_tag, options = {})
      feed_classes.each do |k|
        k.elements element_tag, options
      end
    end

    def self.add_common_feed_entry_element(element_tag, options = {})
      call_on_each_feed_entry :element, element_tag, options
    end

    def self.add_common_feed_entry_elements(element_tag, options = {})
      call_on_each_feed_entry :elements, element_tag, options
    end

    def self.call_on_each_feed_entry(method, *parameters)
      feed_classes.each do |k|
        k.sax_config.collection_elements.each_value do |vl|
          vl.find_all{|v| (v.accessor == 'entries') && (v.data_class.class == Class)}.each do |v|
              v.data_class.send(method, *parameters)
          end
        end
      end
    end

    def self.fetch_and_parse(url)
      response = connection(url).get
      raise FetchFailure.new("Fetch failed - #{response.status}") unless response.success?
      xml = response.body
      parser_klass = determine_feed_parser_for_xml xml
      raise NoParserAvailable.new("No valid parser for XML.") unless parser_klass

      feed = parse_with parser_klass, xml
      feed.feed_url = url
      feed.etag = response.headers['etag'].to_s.gsub(/"/, '')
      feed.last_modified = response.headers['last-modified']
      feed
    end

    def self.connection(url)
      Faraday.new(url: url) do |conn|
        conn.use FaradayMiddleware::FollowRedirects, limit: 3
        conn.adapter :net_http
      end
    end
  end
end
