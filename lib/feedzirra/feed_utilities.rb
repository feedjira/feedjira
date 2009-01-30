module Feedzirra
  module FeedUtilities
    attr_writer :new_entries, :updated
    attr_accessor :etag, :last_modified
    
    def updated?
      @updated
    end
    
    def new_entries
      @new_entries ||= []
    end
  end
end