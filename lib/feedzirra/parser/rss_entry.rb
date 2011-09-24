module Feedzirra

  module Parser
    # Parser for dealing with RDF feed entries.
    class RSSEntry
      include Enumerable
      include SAXMachine
      include FeedEntryUtilities

      element :title
      element :link, :as => :url
      
      element :"dc:creator", :as => :author
      element :author, :as => :author
      element :"content:encoded", :as => :content
      element :description, :as => :summary
      
      element :pubDate, :as => :published
      element :pubdate, :as => :published
      element :"dc:date", :as => :published
      element :"dc:Date", :as => :published
      element :"dcterms:created", :as => :published
      
      
      element :"dcterms:modified", :as => :updated
      element :issued, :as => :published
      elements :category, :as => :categories
      
      element :guid, :as => :entry_id
      
      def each
        @rss_fields ||= self.instance_variables

        @rss_fields.each do |field|
          yield(field.to_s.sub('@', ''), self.instance_variable_get(field))
        end
      end

      def [](field)
        self.instance_variable_get("@#{field.to_s}")
      end

      def []=(field, value)
        self.instance_variable_set("@#{field.to_s}", value)
      end
    end

  end

end
