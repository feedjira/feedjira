# frozen_string_literal: true

module Feedjira
  module FeedUtilities
    UPDATABLE_ATTRIBUTES = %w[title feed_url url last_modified etag].freeze

    attr_writer   :new_entries, :updated, :last_modified
    attr_accessor :etag

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def parse(xml, &)
        xml = strip_whitespace(xml)
        xml = preprocess(xml) if preprocess_xml
        super(xml, &).tap do |feed|
          feed.strip_whitespace! if Feedjira.strip_whitespace
        end
      end

      def preprocess(xml)
        # noop
        xml
      end

      def preprocess_xml=(value)
        @preprocess_xml = value
      end

      def preprocess_xml
        @preprocess_xml
      end

      def strip_whitespace(xml)
        if Feedjira.strip_whitespace
          xml.strip
        else
          xml.lstrip
        end
      end
    end

    def last_modified
      @last_modified ||= entries.reject { |e| e.published.nil? }.max_by(&:published)&.published
    end

    def updated?
      @updated || false
    end

    def new_entries
      @new_entries ||= []
    end

    def new_entries?
      !new_entries.empty?
    end

    def update_from_feed(feed)
      self.new_entries += find_new_entries_for(feed)
      entries.unshift(*new_entries)

      @updated = false

      UPDATABLE_ATTRIBUTES.each do |name|
        @updated ||= update_attribute(feed, name)
      end
    end

    def update_attribute(feed, name)
      old_value = send(name)
      new_value = feed.send(name)

      if old_value == new_value
        false
      else
        send(:"#{name}=", new_value)
        true
      end
    end

    def sanitize_entries!
      entries.each(&:sanitize!)
    end

    def strip_whitespace!
      strip_object_whitespace(self)
      self
    end

    private

    def strip_object_whitespace(object)
      object.instance_variables.each do |name|
        attribute = name.to_s.delete_prefix("@").to_sym
        next unless object.respond_to?(attribute)

        value = object.instance_variable_get(name)
        object.instance_variable_set(name, strip_value_whitespace(value))
      end
    end

    def strip_value_whitespace(value)
      case value
      when String
        value.strip
      when Array
        value.map { |item| strip_value_whitespace(item) }
      else
        strip_object_whitespace(value) if whitespace_container?(value)
        value
      end
    end

    def whitespace_container?(value)
      value.class.name.to_s.start_with?("Feedjira::Parser::") ||
        value.is_a?(Feedjira::FeedUtilities) ||
        value.is_a?(Feedjira::FeedEntryUtilities)
    end

    # This implementation is a hack, which is why it's so ugly. It's to get
    # around the fact that not all feeds have a published date. However,
    # they're always ordered with the newest one first. So we go through the
    # entries just parsed and insert each one as a new entry until we get to
    # one that has the same id as the the newest for the feed.
    def find_new_entries_for(feed)
      return feed.entries if entries.empty?

      latest_entry = entries.first
      found_new_entries = []

      feed.entries.each do |entry|
        break unless new_entry?(entry, latest_entry)

        found_new_entries << entry
      end

      found_new_entries
    end

    def new_entry?(entry, latest)
      nil_ids = entry.entry_id.nil? && latest.entry_id.nil?
      new_id = entry.entry_id != latest.entry_id
      new_url = entry.url != latest.url

      (nil_ids || new_id) && new_url
    end
  end
end
