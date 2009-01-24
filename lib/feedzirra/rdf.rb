module Feedzirra
  class RDF
    def self.will_parse?(xml)
      xml =~ /rdf\:RDF/ || false
    end
  end
end