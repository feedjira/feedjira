module Feedzirra
  module FeedEntryUtilities

    include Enumerable

    def published
      @published ||= @updated
    end

    def parse_datetime(string)
      begin
        DateTime.parse(string).feed_utils_to_gm_time
      rescue
        warn "Failed to parse date #{string.inspect}"
        nil
      end
    end

    ##
    # Returns the id of the entry or its url if not id is present, as some formats don't support it
    def id
      @entry_id ||= @url
    end

    ##
    # Writer for published. By default, we keep the "oldest" publish time found.
    def published=(val)
      parsed = parse_datetime(val)
      @published = parsed if !@published || parsed < @published
    end

    ##
    # Writer for updated. By default, we keep the most recent update time found.
    def updated=(val)
      parsed = parse_datetime(val)
      @updated = parsed if !@updated || parsed > @updated
    end

    def sanitize!
      self.title.sanitize! if self.title
      self.author.sanitize! if self.author
      self.summary.sanitize! if self.summary
      self.content.sanitize! if self.content
      self.image.sanitize! if self.image
    end

    alias_method :last_modified, :published

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
