module Feedzirra
  module FeedUtilities
    UPDATABLE_ATTRIBUTES = %w(title feed_url url)
    
    attr_writer :new_entries, :updated
    attr_accessor :etag, :last_modified
    
    def updated?
      @updated
    end
    
    def new_entries
      @new_entries ||= []
    end
    
    def update_from_feed(feed)
      updated! if UPDATABLE_ATTRIBUTES.any? { |name| updated_attribute?(feed, name) }
    end
    
    private
    
    def updated!
      self.updated = true
    end
    
    def updated_attribute?(feed, name)
      old_value, new_value = send(name), feed.send(name)
      
      if old_value != new_value
        send("#{name}=", new_value)
      end
    end
  end
end