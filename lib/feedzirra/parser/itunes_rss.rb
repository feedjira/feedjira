module Feedzirra

  module Parser
    # iTunes is RSS 2.0 + some apple extensions
    # Source: http://www.apple.com/itunes/whatson/podcasts/specs.html
    class ITunesRSS
      include SAXMachine
      include FeedUtilities

      attr_accessor :feed_url

      # RSS 2.0 elements that need including
      element :copyright
      element :description
      element :language
      element :managingEditor
      element :title
      element :link, :as => :url

      # If author is not present use managingEditor on the channel
      element :"itunes:author", :as => :itunes_author
      element :"itunes:block", :as => :itunes_block
      element :"itunes:image", :value => :href, :as => :itunes_image
      element :"itunes:explicit", :as => :itunes_explicit
      element :"itunes:keywords", :as => :itunes_keywords
      # New URL for the podcast feed
      element :"itunes:new-feed-url", :as => :itunes_new_feed_url
      element :"itunes:subtitle", :as => :itunes_subtitle
      # If summary is not present, use the description tag
      element :"itunes:summary", :as => :itunes_summary

      # iTunes RSS feeds can have multiple main categories...
      # ...and multiple sub-categories per category
      # TODO subcategories not supported correctly - they are at the same level
      #   as the main categories
      elements :"itunes:category", :as => :itunes_categories, :value => :text

      elements :"itunes:owner", :as => :itunes_owners, :class => ITunesRSSOwner

      elements :item, :as => :entries, :class => ITunesRSSItem

      def self.able_to_parse?(xml)
        /xmlns:itunes=\"http:\/\/www.itunes.com\/dtds\/podcast-1.0.dtd\"/i =~ xml
      end

    end

  end

end
