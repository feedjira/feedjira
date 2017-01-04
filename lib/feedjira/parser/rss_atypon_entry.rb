module Feedjira
  module Parser
    # Parser for dealing with Atypon RSS feed entries.
    # URL: https://www.atypon.com/
    class RSSAtyponEntry
      include SAXMachine
      include FeedEntryUtilities

      element :"rss:title", as: :title
      element :"rss:link", as: :url

      element :"dc:creator", as: :author
      element :"rss:author", as: :author
      element :"content:encoded", as: :content
      element :"rss:description", as: :summary

      element :"media:content", as: :image, value: :url
      element :"rss:enclosure", as: :image, value: :url

      element :"rss:pubDate", as: :published
      element :"rss:pubdate", as: :published
      element :"dc:date", as: :published
      element :"dc:Date", as: :published
      element :"dcterms:created", as: :published

      element :"dcterms:modified", as: :updated
      element :"rss:issued", as: :published
      elements :"rss:category", as: :categories

      element :"rss:guid", as: :entry_id
      element :"dc:identifier", as: :entry_id
    end
  end
end
