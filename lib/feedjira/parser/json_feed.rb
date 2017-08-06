module Feedjira
  module Parser
    # Parser for dealing with JSON Feeds.
    class JSONFeed
      include SAXMachine
      include FeedUtilities

      def self.able_to_parse?(json)
        %r{https:\/\/jsonfeed.org\/version\/} =~ json
      end

      def self.parse(json)
        new(JSON.parse(json))
      end

      attr_reader :json, :version, :title, :url, :feed_url, :description,
        :expired, :entries

      def initialize(json)
        @json = json
        @version = json.fetch("version")
        @title = json.fetch("title")
        @url = json.fetch("home_page_url", nil)
        @feed_url = json.fetch("feed_url", nil)
        @description = json.fetch("description", nil)
        @expired = json.fetch("expired", nil)
        @entries = parse_items(json["items"])
      end

      private

      def parse_items(items)
        items.map do |item|
          Feedjira::Parser::JSONFeedItem.new(item)
        end
      end
    end
  end
end
