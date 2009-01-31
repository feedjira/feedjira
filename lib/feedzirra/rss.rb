module Feedzirra
  class RSS
    include SAXMachine
    include FeedUtilities
    element :title
    element :link, :as => :url
    elements :item, :as => :entries, :class => RSSEntry
    
    attr_accessor :feed_url
    
    def self.able_to_parse?(xml)
      xml =~ /rss version\=\"2\.0\"/
    end
  end
end