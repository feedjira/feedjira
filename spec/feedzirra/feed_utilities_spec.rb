require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::FeedUtilities do
  before(:each) do
    @klass = Class.new do
      include Feedzirra::FeedUtilities
    end
  end

  describe "instance methods" do
    it "should provide an updated? accessor" do
      feed = @klass.new
      feed.should_not be_updated
      feed.updated = true
      feed.should be_updated
    end
    
    it "should provide a new_entries accessor" do
      feed = @klass.new
      feed.new_entries.should == []
      feed.new_entries = [:foo]
      feed.new_entries.should == [:foo]
    end
    
    it "should provide an etag accessor" do
      feed = @klass.new
      feed.etag = "foo"
      feed.etag.should == "foo"
    end
    
    it "should provide a last_modified accessor" do
      feed = @klass.new
      time = Time.now
      feed.last_modified = time
      feed.last_modified.should == time
    end
  end
  
  describe "#update_from_feed" do
    before(:each) do
      # I'm using the Atom class when I know I should be using a different one. However, this update_from_feed
      # method would only be called against a feed item.
      @feed = Feedzirra::Atom.new
      @feed.title    = "A title"
      @feed.url      = "http://pauldix.net"
      @feed.feed_url = "http://feeds.feedburner.com/PaulDixExplainsNothing"
      @feed.updated  = false
      @new_feed = @feed.dup
    end
    
    it "should update the title if changed" do
      @new_feed.title = "new title"
      @feed.update_from_feed(@new_feed)
      @feed.title.should == @new_feed.title
      @feed.should be_updated
    end
    
    it "should not update the title if the same" do
      @feed.update_from_feed(@new_feed)
      @feed.should_not be_updated      
    end
    
    it "should update the feed_url if changed" do
      @new_feed.feed_url = "a new feed url"
      @feed.update_from_feed(@new_feed)
      @feed.feed_url.should == @new_feed.feed_url
      @feed.should be_updated
    end
    
    it "should not update the feed_url if the same" do
      @feed.update_from_feed(@new_feed)
      @feed.should_not be_updated
    end
    
    it "should update the url if changed" do
      @new_feed.url = "a new url"
      @feed.update_from_feed(@new_feed)
      @feed.url.should == @new_feed.url
    end
    
    it "should not update the url if not changed" do
      @feed.update_from_feed(@new_feed)
      @feed.should_not be_updated
    end
  end
end