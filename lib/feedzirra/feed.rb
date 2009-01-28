require 'feedzirra/atom'
require 'feedzirra/atom_feed_burner'

module Feedzirra
  class Feed
    def self.parse(xml)
      determine_feed_parser_for_xml(xml).parse(xml)
    end

    def self.determine_feed_parser_for_xml(xml)
      start_of_doc = xml.slice(0, 500)
      feed_classes.detect {|klass| klass.able_to_parse?(start_of_doc)}
    end

    def self.add_feed_class(klass)
      feed_classes << klass
    end
    
    def self.feed_classes
      @feed_classes ||= [RSS, RDF, AtomFeedBurner, Atom]
    end
  end
end