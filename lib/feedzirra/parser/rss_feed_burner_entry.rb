module Feedzirra

  module Parser
    # Parser for dealing with RDF feed entries.
    class RSSFeedBurnerEntry
        include SAXMachine
        include FeedEntryUtilities

        element :title

        element :"feedburner:origLink", :as => :url
        element :link, :as => :url

        element :"dc:creator", :as => :author
        element :author, :as => :author
        element :"content:encoded", :as => :content
        element :description, :as => :summary

        element :"media:content", :as => :image, :value => :url
        element :enclosure, :as => :image, :value => :url

        element :pubDate, :as => :published
        element :pubdate, :as => :published
        element :"dc:date", :as => :published
        element :"dc:Date", :as => :published
        element :"dcterms:created", :as => :published


        element :"dcterms:modified", :as => :updated
        element :issued, :as => :published
        elements :category, :as => :categories

        element :guid, :as => :entry_id

        # If author is not present use author tag on the item
        element :"itunes:author", :as => :itunes_author
        element :"itunes:block", :as => :itunes_block
        element :"itunes:duration", :as => :itunes_duration
        element :"itunes:explicit", :as => :itunes_explicit
        element :"itunes:keywords", :as => :itunes_keywords
        element :"itunes:subtitle", :as => :itunes_subtitle
        # If summary is not present, use the description tag
        element :"itunes:summary", :as => :itunes_summary
        element :enclosure, :value => :length, :as => :enclosure_length
        element :enclosure, :value => :type, :as => :enclosure_type
        element :enclosure, :value => :url, :as => :enclosure_url

        def url
          @url || @link
        end

    end

  end

end
