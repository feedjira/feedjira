# frozen_string_literal: true

require "time"
require "date"

module Feedjira
  # Utility methods for time, date, and string handling that were previously
  # implemented as core extensions
  module Utils
    # Parse a time string and convert it to UTC without raising errors.
    # Parses a flattened 14-digit time (YYYYmmddHHMMMSS) as UTC.
    #
    # === Parameters
    # [datetime<String or Time>] Time definition to be parsed.
    #
    # === Returns
    # A Time instance in UTC or nil if there were errors while parsing.
    def self.parse_time_safely(datetime)
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

    def self.parse_string_safely(string)
      return nil if string.empty?

      if /\A\d{14}\z/.match?(string)
        Time.parse("#{string}Z", true)
      else
        Time.parse(string).utc
      end
    end

    # Convert a Date instance to a Time instance in GMT
    # Based on code from Ruby Cookbook by Lucas Carlson and Leonard Richardson
    #
    # === Parameters
    # [date<Date>] Date instance to convert
    #
    # === Returns
    # A Time instance in GMT
    def self.date_to_gm_time(date)
      if date.respond_to?(:new_offset)
        # DateTime object
        date_to_time(date.new_offset, :gm)
      else
        # Date object - convert to DateTime first
        datetime = date.to_datetime
        date_to_time(datetime.new_offset, :gm)
      end
    end

    def self.date_to_time(dest, method)
      # Convert a fraction of a day to a number of microseconds
      usec = (dest.sec_fraction * (10**6)).to_i
      Time.send(method, dest.year, dest.month, dest.day, dest.hour, dest.min, dest.sec, usec)
    end
    private_class_method :date_to_time

    # Sanitize a string by removing dangerous HTML/XML content
    #
    # === Parameters
    # [string<String>] String to sanitize
    #
    # === Returns
    # A sanitized string
    def self.sanitize_string(string)
      Loofah.scrub_fragment(string, :prune).to_s
    end
  end
end