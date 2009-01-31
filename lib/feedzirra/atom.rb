module Feedzirra
  class Atom
    include SAXMachine
    include FeedUtilities
    element :title
    element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
    element :link, :as => :feed_url, :value => :href, :with => {:type => "application/atom+xml"}
    elements :entry, :as => :entries, :class => AtomEntry
    
    def self.able_to_parse?(xml)
      xml =~ /Atom/
    end
  end
end