require 'sax-machine'
require 'feedzirra/atom_entry'

module Feedzirra
  class Atom
    include SAXMachine
    element :title
    element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
    element :link, :as => :feed_url, :value => :href, :with => {:type => "application/atom+xml"}
    elements :entry, :as => :entries, :class => AtomEntry
    
    def self.will_parse?(xml)
      xml =~ /Atom/ || false
    end
  end
end