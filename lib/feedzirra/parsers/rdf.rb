Feedzirra.parses_feed('RDF', /rdf\:RDF/) do
  element :title
  element :link, :as => :url
  elements :item, :as => :entries, :class => Feedzirra::RDFEntry
end