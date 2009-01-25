require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::AtomFeedBurner do
  describe "#will_parse?" do
    it "should return true for a feedburner atom feed" do
      Feedzirra::AtomFeedBurner.will_parse?(sample_feedburner_atom_feed).should be_true
    end
    
    it "should return false for an rdf feed" do
      Feedzirra::AtomFeedBurner.will_parse?(sample_rdf_feed).should be_false
    end
    
    it "should return false for a regular atom feed" do
      Feedzirra::AtomFeedBurner.will_parse?(sample_atom_feed).should be_false
    end
  end

  describe "parsing" do
    before(:each) do
      @feed = Feedzirra::AtomFeedBurner.parse(sample_feedburner_atom_feed)
    end
    
    it "should parse the title" do
      @feed.title.should == "Paul Dix Explains Nothing"
    end
    
    it "should parse the url" do
      @feed.url.should == "http://www.pauldix.net/"
    end
    
    it "should parse the feed_url" do
      @feed.feed_url.should == "http://feeds.feedburner.com/PaulDixExplainsNothing"
    end
    
    it "should parse entries" do
      @feed.entries.size.should == 5
    end
  end
end