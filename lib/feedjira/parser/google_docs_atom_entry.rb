module Feedjira
  module Parser
    class GoogleDocsAtomEntry
      include SAXMachine
      include FeedEntryUtilities

      element :title
      element :link, :as => :url, :value => :href, :with => {:type => "text/html", :rel => "alternate"}
      element :name, :as => :author
      element :content
      element :summary
      element :published
      element :id, :as => :entry_id
      element :created, :as => :published
      element :issued, :as => :published
      element :updated
      element :modified, :as => :updated
      elements :category, :as => :categories, :value => :term
      elements :link, :as => :links, :value => :href
      element :"docs:md5Checksum", :as => :checksum
      element :"docs:filename", :as => :original_filename
      element :"docs:suggestedFilename", :as => :suggested_filename

      def url
        @url ||= links.first
      end
    end
  end
end
