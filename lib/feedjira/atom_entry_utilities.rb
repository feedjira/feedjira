# frozen_string_literal: true

module Feedjira
  module AtomEntryUtilities
    def self.included(mod)
      mod.class_exec do
        element :title
        element :name, as: :author
        element :content
        element :summary
        element :enclosure, as: :image, value: :href

        element :published
        element :id, as: :entry_id
        element :created, as: :published
        element :issued, as: :published
        element :updated
        element :modified, as: :updated

        elements :category, as: :categories, value: :term

        element :link, as: :url, value: :href, with: {
          type: "text/html",
          rel: "alternate"
        }

        elements :link, as: :links, value: :href
      end
    end

    def url
      @url ||= links.first
    end
  end
end
