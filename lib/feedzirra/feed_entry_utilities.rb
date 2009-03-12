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
    
    ##
    # Writter for published. By default, we keep the "oldest" publish time found.
    def published=(val)
      parsed = parse_datetime(val)
      @published = parsed if !@published || parsed < @published
    end
    
    ##
    # Writter for udapted. By default, we keep the most recenet update time found.
    def updated=(val)
      parsed = parse_datetime(val)
      @updated = parsed if !@updated || parsed > @updated
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
