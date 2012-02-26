module Feedzirra
  module FeedUtilities
    UPDATABLE_ATTRIBUTES = %w(title feed_url url last_modified etag)

    attr_writer   :new_entries, :updated, :last_modified
    attr_accessor :etag

    def last_modified
      @last_modified ||= begin
        entry = entries.reject {|e| e.published.nil? }.sort_by { |entry| entry.published if entry.published }.last
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
      self.entries.unshift(*self.new_entries)

      @updated = false
      UPDATABLE_ATTRIBUTES.each do |name|
        updated = update_attribute(feed, name)
        @updated ||= updated
      end
    end

    def update_attribute(feed, name)
      old_value, new_value = send(name), feed.send(name)

      if old_value != new_value
        send("#{name}=", new_value)
      end
    end

    def sanitize_entries!
      entries.each {|entry| entry.sanitize!}
    end

    private

    def find_new_entries_for(feed)
      # this algorithm does not optimize based on publication date, but always finds new entries
      feed.entries.reject {|entry| self.entries.any? {|e| e.url == entry.url} }
    end

    def existing_entry?(test_entry)
      entries.any? { |entry| entry.url == test_entry.url }
    end
  end
end
