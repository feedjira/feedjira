module Feedzirra
  module FeedUtilities
    attr_writer :new_entries, :updated
    attr_accessor :etag, :last_modified
    
    def updated?
      @updated
    end
    
    def new_entries
      @new_entries ||= []
    end
    
    def update_from_feed(feed)
      if self.title != feed.title
        self.title = feed.title
        self.updated = true
      end
      if self.feed_url != feed.feed_url
        self.feed_url = feed.feed_url
        self.updated = true
      end
      if self.url != feed.url
        self.url = feed.url
        self.updated = true
      end
    end
  end
end