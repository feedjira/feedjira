module Feedzirra
  class AtomFeedBurnerEntry
    include SAXMachine
    include FeedEntryUtilities
    element :title
    element :name, :as => :author
    element :link, :as => :url, :value => :href, :with => {:type => "text/html", :rel => "alternate"}
    element :"feedburner:origLink", :as => :url
    element :summary
    element :content
    element :published
    element :issued, :as => :published
    element :created, :as => :published
    element :modified, :as => :updated
    elements :category, :as => :categories, :value => :term
  end
end