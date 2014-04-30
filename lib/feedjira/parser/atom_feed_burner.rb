module Feedjira

  module Parser
    # Parser for dealing with Feedburner Atom feeds.
    class AtomFeedBurner
      include SAXMachine
      include FeedUtilities
      element :title
      element :subtitle, :as => :description
      element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
      element :link, :as => :feed_url, :value => :href, :with => {:type => "application/atom+xml"}
      elements :"atom10:link", :as => :hubs, :value => :href, :with => {:rel => "hub"}
      elements :entry, :as => :entries, :class => AtomFeedBurnerEntry

      def self.able_to_parse?(xml) #:nodoc:
        ((/Atom/ =~ xml) && (/feedburner/ =~ xml) && !(/\<rss|\<rdf/ =~ xml)) || false
      end

      def self.preprocess(xml)
        Preprocessor.new(xml).to_xml
      end
    end

  end

end
