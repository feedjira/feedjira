module Feedzirra
  module Parser
    autoload :RSS,      'feedzirra/parser/rss'
    autoload :RSSEntry, 'feedzirra/parser/rss_entry'

    autoload :ITunesRSS,      'feedzirra/parser/itunes_rss'
    autoload :ITunesRSSItem,  'feedzirra/parser/itunes_rss_item'
    autoload :ITunesRSSOwner, 'feedzirra/parser/itunes_rss_owner'

    autoload :Atom,                'feedzirra/parser/atom'
    autoload :AtomEntry,           'feedzirra/parser/atom_entry'
    autoload :AtomFeedBurner,      'feedzirra/parser/atom_feed_burner'
    autoload :AtomFeedBurnerEntry, 'feedzirra/parser/atom_feed_burner_entry'
  end
end
