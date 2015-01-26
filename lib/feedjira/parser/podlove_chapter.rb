module Feedjira

  module Parser

    class PodloveChapter

      include SAXMachine
      include FeedEntryUtilities
      attribute :start, :as => :start_ntp
      attribute :title
      attribute :href, :as => :url
      attribute :image

      def start
        return if !start_ntp
        parts = start_ntp.split(':')
        secs = parts[-1].to_f if parts.size >= 1
        secs += 60*parts[-2].to_i if parts.size >= 2
        secs += 60*60*parts[-3].to_i if parts.size >= 3
        secs
      end

    end

  end

end
