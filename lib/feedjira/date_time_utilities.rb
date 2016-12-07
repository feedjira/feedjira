module Feedjira
  module DateTimeUtilities
    # This is our date parsing heuristic.
    # Date Parsers are attempted in order.
    DATE_PARSERS = [
      DateTimePatternParser,
      DateTimeLanguageParser,
      DateTime
    ].freeze

    # Parse the given string starting with the most common parser (default ruby)
    # and going over all other available parsers
    def parse_datetime(string)
      DATE_PARSERS.find do |parser|
        begin
          return parser.parse(string).feed_utils_to_gm_time
        rescue
          nil
        end
      end
      warn "Failed to parse date #{string.inspect}"
    end
  end
end
