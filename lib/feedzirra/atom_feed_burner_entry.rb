module Feedzirra
  class AtomFeedBurnerEntry
    include SAXMachine
    include FeedEntryUtilities
    element :title
    element :name, :as => :author
    element :"feedburner:origLink", :as => :url
    element :summary
    element :content
    element :published
  end
end