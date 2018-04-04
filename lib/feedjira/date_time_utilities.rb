module Feedjira
  module DateTimeUtilities
    # This is our date parsing heuristic.
    # Date Parsers are attempted in order.
    DATE_PARSERS = [
      DateTimePatternParser,
      DateTimeLanguageParser,
      DateTimeEpochParser,
      DateTime,
    ].freeze

    # Parse the given string starting with the most common parser (default ruby)
    # and going over all other available parsers
    def parse_datetime(string)
      res = DATE_PARSERS.detect do |parser|
        begin
          return parser.parse(string).feed_utils_to_gm_time
        rescue StandardError => e
          Feedjira.logger.debug { "Failed to parse date #{string}" }
          Feedjira.logger.debug(e)
          nil
        end
      end

      Feedjira.logger.warn { "Failed to parse date #{string}" } if res.nil?

      res
    end
  end
end
