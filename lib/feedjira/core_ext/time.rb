require 'time'
require 'date'

# rubocop:disable Style/DocumentationMethod
class Time
  # Parse a time string and convert it to UTC without raising errors.
  # Parses a flattened 14-digit time (YYYYmmddHHMMMSS) as UTC.
  #
  # === Parameters
  # [dt<String or Time>] Time definition to be parsed.
  #
  # === Returns
  # A Time instance in UTC or nil if there were errors while parsing.
  # rubocop:disable Metrics/MethodLength
  def self.parse_safely(dt)
    if dt.is_a?(Time)
      dt.utc
    elsif dt.respond_to?(:to_datetime)
      dt.to_datetime.utc
    elsif dt.respond_to? :to_s
      parse_string_safely dt.to_s
    end
  rescue StandardError => e
    Feedjira.logger.debug { "Failed to parse time #{dt}" }
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
