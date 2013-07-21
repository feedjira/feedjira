module Feedzirra

  module Parser
    # Parser for dealing with Atom feeds.
    class Atom
      include SAXMachine
      include FeedUtilities
      element :title
      element :subtitle, :as => :description
      elements :entry, :as => :entries, :class => AtomEntry
      elements :link, :as => :atom_links, :class => AtomLink
      element :feed, :as => :feed_base, :value => 'xml:base'

      def self.able_to_parse?(xml) #:nodoc:
        /\<feed[^\>]+xmlns=[\"|\'](http:\/\/www\.w3\.org\/2005\/Atom|http:\/\/purl\.org\/atom\/ns\#)[\"|\'][^\>]*\>/ =~ xml
      end

      def xml_base
        return feed_base if feed_base
        return ''
      end

      def url
        sanitize_url link(:alternate).href
      end

      def url=(val)
        link(:alternate).href = val
      end

      def feed_url
        sanitize_url link(:self).href
      end

      def feed_url=(val)
        link(:self).href = val
      end

      def link(rel = :alternate, type = false)
        the_link = atom_links.select do |l|
          l if l.rel == rel && (type ? l.type == type : true)
        end.first

        if !the_link
          the_link = Feedzirra::Parser::AtomLink.new
          the_link.rel = rel
          atom_links << the_link
        end

        the_link
      end

      def links
        atom_links.map { |m| m.href }
      end

      private

      def sanitize_url(url)
        begin
          URI.join(xml_base, url).to_s
        rescue
          url
        end
      end
    end
  end
end
