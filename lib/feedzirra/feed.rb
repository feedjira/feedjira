require 'feedzirra/atom'
require 'feedzirra/atom_feed_burner'

module Feedzirra
  class Feed
    def self.determine_feed_parser_for_xml(xml)
      start_of_doc = xml.slice(0, 500)
      if start_of_doc =~ /Atom/
        atom_feed_classes.detect {|feed_class| feed_class.will_parse?(start_of_doc)} || Atom
      elsif RDF.will_parse?(xml)
        RDF
      end
    end
    
    def self.add_atom_feed_class(klass)
      atom_feed_classes << klass
    end
    
    def self.atom_feed_classes
      @atom_feed_classes ||= [AtomFeedBurner]
    end
  end
end