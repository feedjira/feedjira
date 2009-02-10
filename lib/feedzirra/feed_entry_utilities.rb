module Feedzirra
  module FeedEntryUtilities
    attr_reader :published
    
    def parse_datetime(string)
      DateTime.parse(string).feed_utils_to_gm_time
    end
    
    def published=(val)
      @published = parse_datetime(val)
    end
    
    def sanitized
      dispatcher = Class.new do
        def initialize(entry)
          @entry = entry
        end
        
        def method_missing(method, *args)
          Dryopteris.sanitize(@entry.send(method))
        end
      end
      dispatcher.new(self)
    end
    
    def sanitize!
      self.title   = sanitized.title
      self.author  = sanitized.author
      self.content = sanitized.content
    end
    
    alias_method :last_modified, :published
  end
end
