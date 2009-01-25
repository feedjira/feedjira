module Feedzirra
  module FeedUtilities
    def parse_datetime(string)
      DateTime.parse(string).to_gm_time
    end
    
    def published=(val)
      @published = parse_datetime(val)
    end
  end
end

# Date code pulled from:
# Ruby Cookbook by Lucas Carlson and Leonard Richardson
# Published by O'Reilly
# ISBN: 0-596-52369-6
class Date
  def to_gm_time
    to_time(new_offset, :gm)
  end

  def to_local_time
    to_time(new_offset(DateTime.now.offset-offset), :local)
  end

  private
  def to_time(dest, method)
    #Convert a fraction of a day to a number of microseconds
    usec = (dest.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
    Time.send(method, dest.year, dest.month, dest.day, dest.hour, dest.min,
              dest.sec, usec)
  end
end