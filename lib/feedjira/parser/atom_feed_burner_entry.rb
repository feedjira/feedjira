module Feedjira
  module Parser
    # Parser for dealing with Feedburner Atom feed entries.
    class AtomFeedBurnerEntry
      include SAXMachine
      include FeedEntryUtilities
      include AtomEntryUtilities

      element :"feedburner:origLink", as: :orig_link
      # rubocop:disable Style/AccessModifierDeclarations
      private :orig_link
      # rubocop:enable Style/AccessModifierDeclarations

      element :"media:thumbnail", as: :image, value: :url
      element :"media:content", as: :image, value: :url

      def url
        orig_link || super
      end
    end
  end
end
