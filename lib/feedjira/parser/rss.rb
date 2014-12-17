module Feedjira

  module Parser
    # Parser for dealing with RSS feeds.
    class RSS
      include SAXMachine
      include FeedUtilities
      element :rss, as: :version, value: :version
      element :title
      element :description
      element :link, :as => :url
      elements :item, :as => :entries, :class => RSSEntry
      elements :"atom:link", :as => :hubs, :value => :href, :with => {:rel => "hub"}

      attr_accessor :feed_url

      def self.able_to_parse?(xml) #:nodoc:
        (/\<rss|\<rdf/ =~ xml) && !(/feedburner/ =~ xml)
      end
    end

  end

end
