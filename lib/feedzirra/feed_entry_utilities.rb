module Feedzirra
  module FeedEntryUtilities    
    def published    
      @published || @updated
    end
    
    def parse_datetime(string)
      begin
        DateTime.parse(string).utc
      rescue
        puts "DATE CAN'T BE PARSED: #{string}"
        nil
      end
    end
    
    ##
    # Returns the id of the entry or its url if not id is present, as some formats don't support it
    def id  
      @entry_id || @url
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

    def sanitize!
      self.title.sanitize!   if self.title
      self.author.sanitize!  if self.author
      self.summary.sanitize! if self.summary
      self.content.sanitize! if self.content
    end
    
    alias_method :last_modified, :published
  end
end
