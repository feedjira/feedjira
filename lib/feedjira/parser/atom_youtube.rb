# rubocop:disable Style/DocumentationMethod
module Feedjira
  module Parser
    # Parser for dealing with RSS feeds.
    class AtomYoutube
      include SAXMachine
      include FeedUtilities
      element :title
      element :link, as: :url, value: :href, with: { rel: 'alternate' }
      element :link, as: :feed_url, value: :href, with: { rel: 'self' }
      element :name, as: :author
      element :"yt:channelId", as: :youtube_channel_id

      elements :entry, as: :entries, class: AtomYoutubeEntry

      def self.able_to_parse?(xml) #:nodoc:
        %r{xmlns:yt="http://www.youtube.com/xml/schemas/2015"} =~ xml
      end
    end
  end
end
