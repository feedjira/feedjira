module Feedjira
  module FeedEntryUtilities

    include Enumerable

    def published
      @published ||= @updated
    end


    # FIXME: Create a DateTime utilities method instead
    def parse_datetime(string)
      datetime = DateTime.parse(string) rescue nil
      datetime = parse_datetime_with_patterns(string) rescue nil if datetime.nil?
      datetime = parse_datetime_with_language(string) rescue nil if datetime.nil?
      datetime = datetime.feed_utils_to_gm_time unless datetime.nil?
      warn "Failed to parse date #{string.inspect}" if datetime.nil?
      datetime
    end

    JAPANESE_SYMBOLS = %w(日 月 火 水 木 金 土).freeze

    def prepare(string)
      rgx = Regexp.new("^(#{JAPANESE_SYMBOLS.join('|')}),\s")
      string.gsub(rgx, '')
    end

    # Instead of using ISO 8601 defaults use different patterns to parse date strings
    def parse_datetime_with_patterns(string)
      string = prepare(string)
      patterns = ["%m/%d/%Y %T %p", "%d %m %Y %T %Z"]
      patterns.each do |p|
        begin
        datetime = DateTime.strptime(string,p)
        return datetime
        rescue
        end
      end
      raise "No pattern matched #{string}"
    end

    MONTHS_ENGLISH = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec).freeze
    MONTHS_SPANISH = %w(Ene Feb Mar Abr May Jun Jul Ago Sep Oct Nov Dic).freeze

    def translate(string)
      MONTHS_SPANISH.each_with_index do |m,i|
        rgx = Regexp.new("\s#{m}\s", Regexp::IGNORECASE)
        if string =~ rgx
          return string.gsub(rgx, MONTHS_ENGLISH[i])
        end
      end
      raise "No translation found for #{string}"
    end

    def parse_datetime_with_language(string)
      DateTime.parse(translate(string))
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
      %w[title author summary content image].each do |name|
        if self.respond_to?(name) && self.send(name).respond_to?(:sanitize!)
          self.send(name).send :sanitize!
        end
      end
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
