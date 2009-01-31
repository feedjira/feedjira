puts "Loading AtomFeedBurner"

Feedzirra.parses_feed('AtomFeedBurner', /Atom/, /feedburner/) do
  element :title
  element :link, :as => :url, :value => :href, :with => {:type => "text/html"}
  element :link, :as => :feed_url, :value => :href, :with => {:type => "application/atom+xml"}
  elements :entry, :as => :entries, :class => Feedzirra::AtomFeedBurnerEntry
end