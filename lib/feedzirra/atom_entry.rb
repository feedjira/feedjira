module Feedzirra
  # == Summary
  # Parser for dealing with Atom feed entries.
  #
  # == Attributes
  # * title
  # * url
  # * author
  # * content
  # * summary
  # * published
  # * categories
  class AtomEntry
    include SAXMachine
    include FeedEntryUtilities
    element :title
    element :link, :as => :url, :value => :href, :with => {:type => "text/html", :rel => "alternate"}
    element :name, :as => :author
    element :content
    element :summary
    element :published
    element :created, :as => :published
    elements :category, :as => :categories, :value => :term
  end
end