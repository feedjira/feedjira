require 'sax-machine'
require 'feedzirra/feed_utilities'

module Feedzirra
  class RSSEntry
    include SAXMachine
    include FeedUtilities
    element :title
    element :link, :as => :url
    element :"dc:creator", :as => :author
    element :"content:encoded", :as => :content
    element :description, :as => :summary
    element :pubDate, :as => :published
  end
end