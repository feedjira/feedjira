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
      elements :link, :as => :links, :value => :href
      elements :entry, :as => :entries, :class => AtomEntry
      
      def self.able_to_parse?(xml) #:nodoc:
        xml =~ /\<feed[^\>]+xmlns=[\"|\'](http:\/\/www\.w3\.org\/2005\/Atom|http:\/\/purl\.org\/atom\/ns\#)[\"|\'][^\>]*\>/
      end
    
      # TODO: Change parse override to a universal wrapper with callbacks, i.e. preprocess
      def self.parse(xml)
        xml = preprocess(xml)
        super(xml)
      end
      
      # TODO: Change preprocess as a universal callback for :parse
      # TODO: Possibly read preprocess configuration off of :element definitions of Atom and AtomEntry
      def self.preprocess(xml)
        xml = Nokogiri::XML(xml)
        xml.search("entry > content").each do |node|
          node.content = CGI.unescape_html(node.inner_html) unless node.cdata?
        end
        xml.to_xml
      end
      
      def url
        @url || links.last
      end
      
      def feed_url
        @feed_url || links.first
      end
    end
  end
  
end