# rubocop:disable Style/Documentation
# rubocop:disable Style/DocumentationMethod
module Feedjira
  module DateTimeUtilities
    class DateTimeLanguageParser
      MONTHS_ENGLISH =
        %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec).freeze
      MONTHS_SPANISH =
        %w(Ene Feb Mar Abr May Jun Jul Ago Sep Oct Nov Dic).freeze

      def self.parse(string)
        DateTime.parse(translate(string))
      end

      def self.translate(string)
        MONTHS_SPANISH.each_with_index do |m, i|
          rgx = Regexp.new("\s#{m}\s", Regexp::IGNORECASE)
          return string.gsub(rgx, MONTHS_ENGLISH[i]) if string =~ rgx
        end
        raise "No translation found for #{string}"
      end
    end
  end
end
