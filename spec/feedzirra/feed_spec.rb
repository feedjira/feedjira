require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::Feed do
  describe "#determine_feed_parser_for_xml" do
    it "should return a Feedzirra::Atom object for an atom feed" do
      Feedzirra::Feed.determine_feed_parser_for_xml(sample_atom_feed).should == Feedzirra::Atom
    end
    
    it "should return a Feedzirra::AtomFeedBurner object for an atom feedburner feed" do
      Feedzirra::Feed.determine_feed_parser_for_xml(sample_feedburner_atom_feed).should == Feedzirra::AtomFeedBurner
    end
    
    it "should return a Feedzirra::RDF object for an rdf/rss 1.0 feed" do
      Feedzirra::Feed.determine_feed_parser_for_xml(sample_rdf_feed).should == Feedzirra::RDF
    end
  end
  
  describe "adding feed types" do
    it "should be able to add an atom feed type" do
      @klass = Class.new
      Feedzirra::Feed.add_atom_feed_class(@klass)
      Feedzirra::Feed.atom_feed_classes.last.should == @klass
    end
  end
end