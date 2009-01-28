require 'sax-machine'
require 'feedzirra/atom_feed_burner_entry'

module Feedzirra
  class AtomFeedBurner
    include SAXMachine
    element :title
    element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
    element :link, :as => :feed_url, :value => :href, :with => {:type => "application/atom+xml"}
    elements :entry, :as => :entries, :class => AtomFeedBurnerEntry

    def self.able_to_parse?(xml)
      (xml =~ /Atom/ && xml =~ /feedburner/) || false
    end
  end
end