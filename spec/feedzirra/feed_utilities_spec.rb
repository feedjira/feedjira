require File.dirname(__FILE__) + '/../spec_helper'
require 'rubygems'
require 'active_support'

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
      feed.last_modified.class.should == Time
    end
    
    it "should return new_entries? as true when entries are put into new_entries" do
      feed = @klass.new
      feed.new_entries << :foo
      feed.should have_new_entries
    end
    
    it "should return a last_modified value from the entry with the most recent published date if the last_modified date hasn't been set" do
      feed = Feedzirra::Parser::Atom.new
      entry =Feedzirra::Parser::AtomEntry.new
      entry.published = Time.now.to_s
      feed.entries << entry
      feed.last_modified.should == entry.published
    end
    
    it "should not throw an error if one of the entries has published date of nil" do
      feed = Feedzirra::Parser::Atom.new
      entry = Feedzirra::Parser::AtomEntry.new
      entry.published = Time.now.to_s
      feed.entries << entry
      feed.entries << Feedzirra::Parser::AtomEntry.new
      feed.last_modified.should == entry.published
    end
  end
  
  describe "#update_from_feed" do
    describe "updating feed attributes" do
      before(:each) do
        # I'm using the Atom class when I know I should be using a different one. However, this update_from_feed
        # method would only be called against a feed item.
        @feed = Feedzirra::Parser::Atom.new
        @feed.title    = "A title"
        @feed.url      = "http://pauldix.net"
        @feed.feed_url = "http://feeds.feedburner.com/PaulDixExplainsNothing"
        @feed.updated  = false
        @updated_feed = @feed.dup
      end
    
      it "should update the title if changed" do
        @updated_feed.title = "new title"
        @feed.update_from_feed(@updated_feed)
        @feed.title.should == @updated_feed.title
        @feed.should be_updated
      end
    
      it "should not update the title if the same" do
        @feed.update_from_feed(@updated_feed)
        @feed.should_not be_updated      
      end
    
      it "should update the feed_url if changed" do
        @updated_feed.feed_url = "a new feed url"
        @feed.update_from_feed(@updated_feed)
        @feed.feed_url.should == @updated_feed.feed_url
        @feed.should be_updated
      end
    
      it "should not update the feed_url if the same" do
        @feed.update_from_feed(@updated_feed)
        @feed.should_not be_updated
      end
    
      it "should update the url if changed" do
        @updated_feed.url = "a new url"
        @feed.update_from_feed(@updated_feed)
        @feed.url.should == @updated_feed.url
      end
    
      it "should not update the url if not changed" do
        @feed.update_from_feed(@updated_feed)
        @feed.should_not be_updated
      end
    end
    
    describe "updating entries" do
      before(:each) do
        # I'm using the Atom class when I know I should be using a different one. However, this update_from_feed
        # method would only be called against a feed item.
        @feed = Feedzirra::Parser::Atom.new
        @feed.title    = "A title"
        @feed.url      = "http://pauldix.net"
        @feed.feed_url = "http://feeds.feedburner.com/PaulDixExplainsNothing"
        @feed.updated  = false
        @updated_feed = @feed.dup
        @old_entry = Feedzirra::Parser::AtomEntry.new
        @old_entry.url = "http://pauldix.net/old.html"
        @old_entry.published = Time.now.to_s
        @new_entry = Feedzirra::Parser::AtomEntry.new    
        @new_entry.url = "http://pauldix.net/new.html"
        @new_entry.published = (Time.now + 10).to_s     
        @feed.entries << @old_entry
        @updated_feed.entries << @new_entry
        @updated_feed.entries << @old_entry
      end
      
      it "should update last-modified from the latest entry date" do
        @feed.update_from_feed(@updated_feed)
        @feed.last_modified.should == @new_entry.published    
      end
      
      it "should put new entries into new_entries" do
        @feed.update_from_feed(@updated_feed)
        @feed.new_entries.should == [@new_entry]
      end
      
      it "should also put new entries into the entries collection" do
        @feed.update_from_feed(@updated_feed)
        @feed.entries.should include(@new_entry)
        @feed.entries.should include(@old_entry)
      end
    end
  end
end