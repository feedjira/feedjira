module Feedzirra
  module FeedUtilities
    UPDATABLE_ATTRIBUTES = %w(title feed_url url)
    
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
      self.last_modified = [feed.last_modified, last_modified].max
      self.entries += (self.new_entries += find_new_entries_for(feed))
      
      updated! if UPDATABLE_ATTRIBUTES.any? { |name| updated_attribute?(feed, name) }
    end
    
    private
    
    def updated!
      self.updated = true
    end
    
    def find_new_entries_for(feed)
      feed.entries.inject([]) { |result, entry| result << entry unless entries.include?(entry); result }
    end
    
    def updated_attribute?(feed, name)
      old_value, new_value = send(name), feed.send(name)
      
      if old_value != new_value
        send("#{name}=", new_value)
      end
    end
  end
end