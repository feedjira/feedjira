# rubocop:disable Style/Documentation
# rubocop:disable Style/DocumentationMethod
module Feedjira
  module DateTimeUtilities
    class DateTimeEpochParser
      def self.parse(string)
        epoch_time = string.to_i
        return Time.at(epoch_time).to_datetime if epoch_time.to_s == string
        raise "#{string} is not a valid epoch time"
      end
    end
  end
end
