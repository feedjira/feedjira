module Feedzirra

  module Parser
    # Parser for dealing with RDF feed entries.
    class RSSEntry
      include SAXMachine
      include FeedEntryUtilities

      element :title
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
    end

  end

end
