module Feedzirra
  module Parser
    class GoogleDocsAtomEntry
      include SAXMachine
      include FeedEntryUtilities

      element :title
      element :link, :as => :url, :value => :href, :with => {:type => "text/html", :rel => "alternate"}
      element :name, :as => :author
      element :content, :as => :download_url, :value => :src
      element :content, :as => :mime_type, :value => :type
      element :summary
      element :published
      element :id, :as => :entry_id
      element :created, :as => :published
      element :issued, :as => :published
      element :updated
      element :modified, :as => :updated
      elements :category, :as => :categories, :value => :term
      elements :link, :as => :links, :value => :href
      element :link, :as => :parent_collection_title, :value => :title, :with => { :rel => 'http://schemas.google.com/docs/2007#parent' }
      element :link, :as => :parent_collection_url, :value => :href, :with => { :rel => 'http://schemas.google.com/docs/2007#parent' }
      element :"docs:md5Checksum", :as => :checksum
      element :"docs:filename", :as => :original_filename
      element :"docs:suggestedFilename", :as => :suggested_filename
      element :"gd:resourceId", :as => :resource_id

      def url
        @url ||= links.first
      end
    end
  end
end
