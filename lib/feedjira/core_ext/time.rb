require 'time'
require 'date'

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
    if dt.is_a?(Time)
      dt.utc
    elsif dt.respond_to?(:empty?) && dt.empty?
      nil
    elsif dt.respond_to?(:to_datetime)
      dt.to_datetime.utc
    elsif dt.to_s =~ /\A\d{14}\z/
      parse("#{dt}Z", true)
    else
      parse(dt.to_s).utc
    end
  rescue StandardError
    nil
  end unless method_defined?(:parse_safely)
end
