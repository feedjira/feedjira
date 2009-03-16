module Feedzirra
  # == Summary
  # Parser for dealing with RDF feed entries.
  #
  # == Attributes
  # * title
  # * url
  # * author
  # * content
  # * summary
  # * published
  class RDFEntry
    include SAXMachine
    include FeedEntryUtilities
    element :title
    element :link, :as => :url
    element :"dc:creator", :as => :author
    element :"content:encoded", :as => :content
    element :description, :as => :summary
    element :"dc:date", :as => :published
  end
end