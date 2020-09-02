# frozen_string_literal: true

module Feedjira
  module DateTimeUtilities
    class DateTimePatternParser
      # Japanese Symbols are required for strange Date Strings like
      # '水, 31 8 2016 07:37:00 PDT'
      JAPANESE_SYMBOLS = %w[日 月 火 水 木 金 土].freeze
      PATTERNS = ["%m/%d/%Y %T %p", "%d %m %Y %T %Z"].freeze

      def self.parse(string)
        PATTERNS.each do |p|
          datetime = DateTime.strptime(prepare(string), p)
          return datetime
        rescue StandardError => e
          Feedjira.logger.debug("Failed to parse date #{string}")
          Feedjira.logger.debug(e)
          nil
        end
        raise "No pattern matched #{string}"
      end

      def self.prepare(string)
        rgx = Regexp.new("^(#{JAPANESE_SYMBOLS.join('|')}),\s")
        string.gsub(rgx, "")
      end
      private_class_method :prepare
    end
  end
end
