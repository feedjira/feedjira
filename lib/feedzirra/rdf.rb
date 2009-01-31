module Feedzirra
  class RDF
    include SAXMachine
    include FeedUtilities
    element :title
    element :link, :as => :url
    elements :item, :as => :entries, :class => RDFEntry

    attr_accessor :feed_url
    
    def self.able_to_parse?(xml)
      xml =~ /rdf\:RDF/ || false
    end
  end
end