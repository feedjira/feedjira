module Feedzirra
  module FeedUtilities
    UPDATABLE_ATTRIBUTES = %w(title feed_url url last_modified)
    
    attr_writer   :new_entries, :updated, :last_modified
    attr_accessor :etag

    def last_modified
      @last_modified ||= begin
        entry = entries.sort_by { |entry| entry.published }.last
        entry ? entry.published : nil
      end
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
      self.new_entries += find_new_entries_for(feed)
      self.entries += self.new_entries
      
      updated! if UPDATABLE_ATTRIBUTES.any? { |name| updated_attribute?(feed, name) }
    end
    
    private
    
    def updated!
      self.updated = true
    end
    
    def find_new_entries_for(feed)
      feed.entries.inject([]) { |result, entry| result << entry unless existing_entry?(entry); result }
    end
    
    def existing_entry?(test_entry)
      entries.any? { |entry| entry.url == test_entry.url }
    end
    
    def updated_attribute?(feed, name)
      old_value, new_value = send(name), feed.send(name)
      
      if old_value != new_value
        send("#{name}=", new_value)
      end
    end
  end
end