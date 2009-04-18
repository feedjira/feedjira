module Feedzirra
  
  module Parser
    # == Summary
    # Parser for dealing with Atom feeds.
    #
    # == Attributes
    # * title
    # * feed_url
    # * url
    # * entries
    class Atom
      include SAXMachine
      include FeedUtilities
      element :title
      element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
      element :link, :as => :feed_url, :value => :href, :with => {:type => "application/atom+xml"}
      elements :entry, :as => :entries, :class => AtomEntry

      def self.able_to_parse?(xml) #:nodoc:
        xml =~ /(Atom)|(#{Regexp.escape("http://purl.org/atom")})/
      end
    end
  end
  
end