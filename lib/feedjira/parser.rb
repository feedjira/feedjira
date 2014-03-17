module Feedjira
  module Parser
    autoload :RSS,                'feedjira/parser/rss'
    autoload :RSSEntry,           'feedjira/parser/rss_entry'
    autoload :RSSFeedBurner,      'feedjira/parser/rss_feed_burner'
    autoload :RSSFeedBurnerEntry, 'feedjira/parser/rss_feed_burner_entry'

    autoload :ITunesRSS,      'feedjira/parser/itunes_rss'
    autoload :ITunesRSSItem,  'feedjira/parser/itunes_rss_item'
    autoload :ITunesRSSOwner, 'feedjira/parser/itunes_rss_owner'

    autoload :GoogleDocsAtom,      'feedjira/parser/google_docs_atom'
    autoload :GoogleDocsAtomEntry, 'feedjira/parser/google_docs_atom_entry'

    autoload :Atom,                'feedjira/parser/atom'
    autoload :AtomEntry,           'feedjira/parser/atom_entry'
    autoload :AtomFeedBurner,      'feedjira/parser/atom_feed_burner'
    autoload :AtomFeedBurnerEntry, 'feedjira/parser/atom_feed_burner_entry'
  end
end
