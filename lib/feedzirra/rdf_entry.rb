require 'sax-machine'
require 'feedzirra/feed_utilities'

module Feedzirra
  class RDFEntry
    include SAXMachine
    include FeedUtilities
    element :title
    element :link, :as => :url
    element :"dc:creator", :as => :author
    element :"content:encoded", :as => :content
    element :description, :as => :summary
    element :"dc:date", :as => :published
  end
end