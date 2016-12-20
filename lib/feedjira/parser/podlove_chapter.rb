# rubocop:disable Style/Documentation
# rubocop:disable Style/DocumentationMethod
module Feedjira
  module Parser
    class PodloveChapter
      include SAXMachine
      include FeedEntryUtilities
      attribute :start, as: :start_ntp
      attribute :title
      attribute :href, as: :url
      attribute :image

      def start
        return unless start_ntp
        parts = start_ntp.split(':')
        parts.reverse.to_enum.with_index.map do |part, index|
          part.to_f * (60**index)
        end.reduce(:+)
      end
    end
  end
end
