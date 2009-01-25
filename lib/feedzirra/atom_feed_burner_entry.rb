require 'feedzirra/feed_utilities'

module Feedzirra
  class AtomFeedBurnerEntry
    include SAXMachine
    include FeedUtilities
    element :title
    element :name, :as => :author
    element "feedburner:origLink", :as => :url
    element :summary
    element :content
    element :published
  end
end