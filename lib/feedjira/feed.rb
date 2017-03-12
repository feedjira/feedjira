# rubocop:disable Style/Documentation
# rubocop:disable Style/DocumentationMethod
module Feedjira
  class Feed
    class << self
      def parse_with(parser, xml, &block)
        parser.parse xml, &block
      end

      def parse(xml, &block)
        parser = determine_feed_parser_for_xml(xml)
        raise NoParserAvailable, 'No valid parser for XML.' unless parser
        parse_with parser, xml, &block
      end

      def determine_feed_parser_for_xml(xml)
        start_of_doc = xml.slice(0, 2000)
        feed_classes.detect { |klass| klass.able_to_parse?(start_of_doc) }
      end

      def add_feed_class(klass)
        feed_classes.unshift klass
      end

      def feed_classes
        @feed_classes ||= Feedjira.parsers
      end

      def reset_parsers!
        @feed_classes = nil
      end

      def add_common_feed_element(element_tag, options = {})
        feed_classes.each do |k|
          k.element element_tag, options
        end
      end

      def add_common_feed_elements(element_tag, options = {})
        feed_classes.each do |k|
          k.elements element_tag, options
        end
      end

      def add_common_feed_entry_element(element_tag, options = {})
        call_on_each_feed_entry :element, element_tag, options
      end

      def add_common_feed_entry_elements(element_tag, options = {})
        call_on_each_feed_entry :elements, element_tag, options
      end

      def call_on_each_feed_entry(method, *parameters)
        feed_classes.each do |klass|
          klass.sax_config.collection_elements.each_value do |value|
            collection_configs = value.select do |v|
              v.accessor == 'entries' && v.data_class.class == Class
            end

            collection_configs.each do |config|
              config.data_class.send(method, *parameters)
            end
          end
        end
      end

      def fetch_and_parse(url)
        response = connection(url).get
        unless response.success?
          raise FetchFailure, "Fetch failed - #{response.status}"
        end
        feed = parse response.body
        feed.feed_url = url
        feed.etag = response.headers['etag'].to_s.delete '"'

        feed.last_modified = parse_last_modified(response)
        feed
      end

      # rubocop:disable LineLength
      def connection(url)
        Faraday.new(url: url, headers: headers, request: request_options) do |conn|
          conn.use FaradayMiddleware::FollowRedirects, limit: Feedjira.follow_redirect_limit
          conn.adapter(*Faraday.default_adapter)
        end
      end
      # rubocop:enable LineLength

      private

      def headers
        {
          user_agent: Feedjira.user_agent
        }
      end

      def request_options
        {
          timeout: Feedjira.request_timeout
        }
      end

      def parse_last_modified(response)
        lm = response.headers['last-modified']
        DateTime.parse(lm).to_time
      rescue StandardError => e
        Feedjira.logger.warn { "Failed to parse last modified '#{lm}'" }
        Feedjira.logger.debug(e)
        nil
      end
    end
  end
end
