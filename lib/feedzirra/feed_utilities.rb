module Feedzirra
  module FeedUtilities
    attr_writer   :last_modified, :new_entries, :updated
    attr_accessor :etag

    def last_modified
      @last_modified ||= entries.inject(Time.now - 10.years) {|last_time, entry| entry.published > last_time ? entry.published : last_time}
    end
    
    def updated?
      @updated
    end
    
    def new_entries
      @new_entries ||= []
    end
    
    def has_new_entries?
      new_entries.size > 0
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
      
      # now the entries. btw, these lines are pretty ugly, but they do the trick
      self.last_modified = feed.entries.inject(last_modified) {|last, entry| entry.published > last ? entry.published : last}
      self.new_entries += feed.entries.map {|entry| entry unless self.entries.detect {|e| e.url == entry.url}}.compact
      self.entries += self.new_entries
    end
  end
end