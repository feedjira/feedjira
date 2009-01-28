require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::Feed do
  describe "#parse" do # many of these tests are redundant with the specific feed type tests, but I put them here for completeness
    it "should parse an rdf feed" do
      feed = Feedzirra::Feed.parse(sample_rdf_feed)
      feed.class.should == Feedzirra::RDF
      feed.title.should == "HREF Considered Harmful"
      feed.entries.size.should == 10
    end
    
    it "should parse an rss feed" do
      feed = Feedzirra::Feed.parse(sample_rss_feed)
      feed.class.should == Feedzirra::RSS
      feed.title.should == "Tender Lovemaking"
      feed.entries.size.should == 10
    end
    
    it "should parse an atom feed" do
      feed = Feedzirra::Feed.parse(sample_atom_feed)
      feed.class.should == Feedzirra::Atom
      feed.title.should == "Amazon Web Services Blog"
      feed.entries.size.should == 10
    end
    
    it "should parse an feedburner atom feed" do
      feed = Feedzirra::Feed.parse(sample_feedburner_atom_feed)
      feed.class.should == Feedzirra::AtomFeedBurner
      feed.title.should == "Paul Dix Explains Nothing"
      feed.entries.size.should == 5
    end
  end
  
  describe "#determine_feed_parser_for_xml" do
    it "should return the Feedzirra::Atom class for an atom feed" do
      Feedzirra::Feed.determine_feed_parser_for_xml(sample_atom_feed).should == Feedzirra::Atom
    end
    
    it "should return the Feedzirra::AtomFeedBurner class for an atom feedburner feed" do
      Feedzirra::Feed.determine_feed_parser_for_xml(sample_feedburner_atom_feed).should == Feedzirra::AtomFeedBurner
    end
    
    it "should return the Feedzirra::RDF class for an rdf/rss 1.0 feed" do
      Feedzirra::Feed.determine_feed_parser_for_xml(sample_rdf_feed).should == Feedzirra::RDF
    end
    
    it "should return the Feedzirra::RSS object for an rss 2.0 feed" do
      Feedzirra::Feed.determine_feed_parser_for_xml(sample_rss_feed).should == Feedzirra::RSS
    end
  end
  
  describe "adding feed types" do
    it "should be able to add a feed type" do
      @klass = Class.new
      Feedzirra::Feed.add_feed_class(@klass)
      Feedzirra::Feed.feed_classes.last.should == @klass
    end
  end
end