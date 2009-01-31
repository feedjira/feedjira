Feedzirra.parses_feed('RSS', /rss version\=\"2\.0\"/) do
  element :title
  element :link, :as => :url
  elements :item, :as => :entries, :class => Feedzirra::RSSEntry
end