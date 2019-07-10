module Feedjira
  module Parser
    # Parser for dealing with RDF feed entries.
    class RSSFeedBurnerEntry
      include SAXMachine
      include FeedEntryUtilities
      include RSSEntryUtilities

      element :"feedburner:origLink", as: :orig_link
      # rubocop:disable Style/AccessModifierDeclarations
      private :orig_link
      # rubocop:enable Style/AccessModifierDeclarations

      def url
        orig_link || super
      end
    end
  end
end
