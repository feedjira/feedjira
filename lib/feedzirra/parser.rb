module Feedzirra
  def self.parses_feed(name, *patterns, &block)
    parser = Class.new do
      attr_accessor :feed_url
      
      include SAXMachine
      include FeedUtilities
      
      class_eval(&block)
    end
    
    parser.metaclass.instance_eval do
      define_method("able_to_parse?") do |content|
        patterns.all? { |pattern| content =~ pattern }
      end
    end
    
    Feed.add_feed_class(parser)
    const_set(name, parser)
  end
end