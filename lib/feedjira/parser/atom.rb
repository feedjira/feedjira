module Feedjira
  module Parser
    # Parser for dealing with Atom feeds.
    class Atom
      include SAXMachine
      include FeedUtilities
      element :title
      element :subtitle, :as => :description
      element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
      element :link, :as => :feed_url, :value => :href, :with => {:rel => "self"}
      elements :link, :as => :links, :value => :href
      elements :link, :as => :hubs, :value => :href, :with => {:rel => "hub"}
      elements :entry, :as => :entries, :class => AtomEntry

      def self.able_to_parse?(xml) #:nodoc:
        /\<feed[^\>]+xmlns\s?=\s?[\"|\'](http:\/\/www\.w3\.org\/2005\/Atom|http:\/\/purl\.org\/atom\/ns\#)[\"|\'][^\>]*\>/ =~ xml
      end

      def url
        @url || (links - [feed_url]).last || links.last
      end

      def feed_url
        @feed_url ||= links.first
      end

      def self.preprocess(xml)
        Preprocessor.new(xml).to_xml
      end
    end
  end
end
