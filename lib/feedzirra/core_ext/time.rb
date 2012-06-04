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
  def self.parse_safely(dt)
    if dt
      case
      when dt.is_a?(Time)
        dt.utc
      when dt.respond_to?(:empty?) && dt.empty?
        nil
      when dt.to_s =~ /\A\d{14}\z/
        parse("#{dt.to_s}Z", true)
      else
        parse(dt.to_s, true).utc
      end
    end
  rescue StandardError
    nil
  end unless method_defined?(:parse_safely)
end
