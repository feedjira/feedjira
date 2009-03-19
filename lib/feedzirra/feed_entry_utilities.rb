module Feedzirra
  module FeedEntryUtilities
    attr_reader :published
    
    def parse_datetime(string)
      DateTime.parse(string).feed_utils_to_gm_time
    end
    
    def published=(val)
      @published = parse_datetime(val)
    end

    def sanitize!
      self.title.sanitize!
      self.author.sanitize!
      self.content.sanitize!
    end
    
    alias_method :last_modified, :published
  end
end
