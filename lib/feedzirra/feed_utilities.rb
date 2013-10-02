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
        @updated ||= update_attribute(feed, name)
      end
    end

    def update_attribute(feed, name)
      old_value, new_value = send(name), feed.send(name)

      if old_value != new_value
        send("#{name}=", new_value)
        true
      else
        false
      end
    end

    def sanitize_entries!
      entries.each {|entry| entry.sanitize!}
    end

    private

    def find_new_entries_for(feed)
      # this implementation is a hack, which is why it's so ugly.
      # it's to get around the fact that not all feeds have a published date.
      # however, they're always ordered with the newest one first.
      # So we go through the entries just parsed and insert each one as a new entry
      # until we get to one that has the same id as the the newest for the feed
      return feed.entries if self.entries.length == 0
      latest_entry = self.entries.first
      found_new_entries = []
      feed.entries.each do |entry|
        break if entry.id == latest_entry.id
        found_new_entries << entry
      end
      found_new_entries
    end

    def existing_entry?(test_entry)
      entries.any? { |entry| entry.id == test_entry.id }
    end
  end
end
