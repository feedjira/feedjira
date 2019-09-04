# frozen_string_literal: true

module Feedjira
  module RSSEntryUtilities
    def self.included(mod)
      mod.class_exec do
        element :title

        element :"content:encoded", as: :content
        element :description, as: :summary

        element :link, as: :url

        element :author
        element :"dc:creator", as: :author

        element :pubDate, as: :published
        element :pubdate, as: :published
        element :issued, as: :published
        element :"dc:date", as: :published
        element :"dc:Date", as: :published
        element :"dcterms:created", as: :published

        element :"dcterms:modified", as: :updated

        element :guid, as: :entry_id
        element :"dc:identifier", as: :dc_identifier

        element :"media:thumbnail", value: :url, as: :media_thumbnail
        element :"media:content", value: :url, as: :media_content

        element :enclosure, value: :length, as: :enclosure_length
        element :enclosure, value: :type, as: :enclosure_type
        element :enclosure, value: :url, as: :enclosure_url

        elements :category, as: :categories
      end
    end

    attr_reader :url

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def id
      @entry_id ||= @dc_identifier || @url
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
end
