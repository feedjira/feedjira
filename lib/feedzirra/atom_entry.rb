module Feedzirra
  class AtomEntry
    include SAXMachine
    include FeedEntryUtilities
    element :title
    element :link, :as => :url, :value => :href, :with => {:type => "text/html", :rel => "alternate"}
    element :name, :as => :author
    element :content
    element :summary
    element :published
    element :id
    element :created, :as => :published
    element :issued, :as => :published
    element :updated
    element :modified, :as => :updated
    elements :category, :as => :categories, :value => :term
  end
end