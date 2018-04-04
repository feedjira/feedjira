require "time"
require "date"

class Time
  # Parse a time string and convert it to UTC without raising errors.
  # Parses a flattened 14-digit time (YYYYmmddHHMMMSS) as UTC.
  #
  # === Parameters
  # [dt<String or Time>] Time definition to be parsed.
  #
  # === Returns
  # A Time instance in UTC or nil if there were errors while parsing.
  def self.parse_safely(datetime)
    if datetime.is_a?(Time)
      datetime.utc
    elsif datetime.respond_to?(:to_datetime)
      datetime.to_datetime.utc
    elsif datetime.respond_to? :to_s
      parse_string_safely datetime.to_s
    end
  rescue StandardError => e
    Feedjira.logger.debug { "Failed to parse time #{datetime}" }
    Feedjira.logger.debug(e)
    nil
  end

  def self.parse_string_safely(string)
    return nil if string.empty?

    if string =~ /\A\d{14}\z/
      parse("#{string}Z", true)
    else
      parse(string).utc
    end
  end
end
