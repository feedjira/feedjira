# rubocop:disable Style/DocumentationMethod
module Feedjira
  module Parser
    # Parser for dealing with Feedburner Atom feeds.
    class AtomFeedBurner
      include SAXMachine
      include FeedUtilities

      element :title
      element :subtitle, as: :description
      element :link, as: :url, value: :href, with: { type: 'text/html' }
      element :link, as: :feed_url, value: :href, with: { type: 'application/atom+xml' } # rubocop:disable Metrics/LineLength
      elements :"atom10:link", as: :hubs, value: :href, with: { rel: 'hub' }
      elements :entry, as: :entries, class: AtomFeedBurnerEntry

      def self.able_to_parse?(xml)
        ((/Atom/ =~ xml) && (/feedburner/ =~ xml) && !(/\<rss|\<rdf/ =~ xml)) || false # rubocop:disable Metrics/LineLength
      end

      def self.preprocess(xml)
        Preprocessor.new(xml).to_xml
      end
    end
  end
end
