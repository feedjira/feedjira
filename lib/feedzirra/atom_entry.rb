require 'feedzirra/feed_utilities'

module Feedzirra
  class AtomEntry
    include SAXMachine
    include FeedUtilities
    element :title
    element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
    element :name, :as => :author
    element :content
    element :summary
    element :published
  end
end