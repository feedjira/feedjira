module Feedzirra

  module Parser
    # Parser for dealing with Atom feed entries.
    class AtomEntry
      include SAXMachine
      include FeedEntryUtilities

      element :title
      element :name, :as => :author
      element :content
      element :summary

      elements :link, :as => :atom_links, :class => AtomLink
      attribute :"xml:base", :as => :base

      element :"media:content", :as => :image, :value => :url
      element :enclosure, :as => :image, :value => :href

      element :published
      element :id, :as => :entry_id
      element :created, :as => :published
      element :issued, :as => :published
      element :updated
      element :modified, :as => :updated
      elements :category, :as => :categories, :value => :term

      def url
        uri_join(base, link.href)
      end

      def url=(val)
        @url = val
      end

      def replies_url
        puts link(:replies).href
        @replies_url ||= uri_join(base, link(:replies).href)
      end

      def replies_feed_url
        @replies_feed_url ||= uri_join(base, link(:replies, 'application/atom+xml').href)
      end

      def link(rel = :alternate, type = false)
        the_link = atom_links.select do |l|
          l if l.rel == rel && (type ? l.type == type : true)
        end.first

        if !the_link
          the_link = AtomLink.new
          the_link.rel = rel
          atom_links << the_link
        end

        the_link
      end

      def links
        atom_links.map { |m| m.href }
      end

      private

      def uri_join(part1, part2)
        return nil if (part1.nil? && part2.nil?) || part2.nil?

        if part1 && part1.match(/:\/\//)
          URI.join(part1, part2).to_s
        else
          ((part1 + part2) if !part1.nil?) or part2
        end
      end
    end
  end
end