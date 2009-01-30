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
end