module Feedjira
  module DateTimeUtilities

    # Japanese Symbols are required for strange Date Strings like '水, 31 8 2016 07:37:00 PDT'
    JAPANESE_SYMBOLS = %w(日 月 火 水 木 金 土).freeze

    # These translations are required for translating abbreviations into english
    MONTHS_ENGLISH = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec).freeze
    MONTHS_SPANISH = %w(Ene Feb Mar Abr May Jun Jul Ago Sep Oct Nov Dic).freeze

    # Parse the given string starting with the most common parser (default ruby)
    # and going over all other available parsers
    def parse_datetime(string)
      datetime = DateTime.parse(string) rescue nil
      datetime = parse_datetime_with_patterns(string) rescue nil if datetime.nil?
      datetime = parse_datetime_with_language(string) rescue nil if datetime.nil?
      datetime = datetime.feed_utils_to_gm_time unless datetime.nil?
      warn "Failed to parse date #{string.inspect}" if datetime.nil?
      datetime
    end

    private    

    # Some DateTimes can be converted to valid ISO 8601 datetimes by simply remove unnescessary prefixes
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

    def parse_datetime_with_language(string)
      DateTime.parse(translate(string))
    end

    # Translate foreign language DateTime strings to english
    def translate(string)
      MONTHS_SPANISH.each_with_index do |m,i|
        rgx = Regexp.new("\s#{m}\s", Regexp::IGNORECASE)
        if string =~ rgx
          return string.gsub(rgx, MONTHS_ENGLISH[i])
        end
      end
      raise "No translation found for #{string}"
    end
  end
end
