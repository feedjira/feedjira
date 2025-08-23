# frozen_string_literal: true

require "time"
require "date"

module Feedjira
  module Util
    # Module for safely parsing time strings
    module ParseTime
      # Parse a time string and convert it to UTC without raising errors.
      # Parses a flattened 14-digit time (YYYYmmddHHMMMSS) as UTC.
      #
      # === Parameters
      # [dt<String or Time>] Time definition to be parsed.
      #
      # === Returns
      # A Time instance in UTC or nil if there were errors while parsing.
      def self.call(datetime)
        if datetime.is_a?(Time)
          datetime.utc
        elsif datetime.respond_to?(:to_datetime)
          datetime.to_time.utc
        else
          parse_string_safely datetime.to_s
        end
      rescue StandardError => e
        Feedjira.logger.debug("Failed to parse time #{datetime}")
        Feedjira.logger.debug(e)
        nil
      end

      # Parse a string safely, handling special 14-digit format
      #
      # === Parameters
      # [string<String>] String to be parsed as time.
      #
      # === Returns
      # A Time instance in UTC or nil if there were errors while parsing.
      def self.parse_string_safely(string)
        return nil if string.empty?

        if /\A\d{14}\z/.match?(string)
          Time.parse("#{string}Z", true)
        else
          Time.parse(string).utc
        end
      end

      private_class_method :parse_string_safely
    end
  end
end
