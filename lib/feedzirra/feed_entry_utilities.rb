module Feedzirra
  module FeedEntryUtilities
    module Sanitize
      def sanitize!
        self.replace(sanitize)
      end
      
      def sanitize
        Dryopteris.sanitize(self)
      end
    end
    
    def published
      @published || @updated
    end
    
    def parse_datetime(string)
      DateTime.parse(string).feed_utils_to_gm_time
    end
    
    def published=(val)
      @published = parse_datetime(val)
    end
    
    def updated=(val)
      @updated = parse_datetime(val)
    end
    
    def content
      @content.extend(Sanitize)
    end
    
    def title
      @title.extend(Sanitize)
    end
    
    def author
      @author.extend(Sanitize)
    end
    
    def sanitize!
      self.title.sanitize!
      self.author.sanitize!
      self.content.sanitize!
    end
    
    alias_method :last_modified, :published
  end
end
