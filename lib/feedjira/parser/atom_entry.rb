module Feedjira

  module Parser
    # Parser for dealing with Atom feed entries.
    class AtomEntry
      include SAXMachine
      include FeedEntryUtilities

      attr_accessor :enclosure_url, :enclosure_type, :enclosure_length

      element :title
      element :link, :as => :url, :value => :href, :with => {:type => "text/html", :rel => "alternate"}
      element :name, :as => :author
      element :content
      element :summary

      element :"media:content", :as => :image, :value => :url
      element :enclosure, :as => :image, :value => :href

      element :published
      element :id, :as => :entry_id
      element :created, :as => :published
      element :issued, :as => :published
      element :updated
      element :modified, :as => :updated
      elements :category, :as => :categories, :value => :term
      elements :link, :as => :links, :value => :href
      elements :link, :as => :enclosures, :value => :href, :with => {:rel => "enclosure"}
      elements :link, :as => :enclosure_types, :value => :type, :with => {:rel => "enclosure"}
      elements :link, :as => :enclosure_lengths, :value => :type, :with => {:rel => "enclosure"}

      def url
        @url ||= links.first
      end

      def enclosure_url
        @enclosure_url ||= enclosures.first
      end

      def enclosure_type
        @enclosure_type ||= enclosures.first
      end

      def enclosure_length
        @enclosure_type ||= enclosures.first
      end

    end

  end

end
