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
  
  describe "header parsing" do
    before(:each) do
      @header = "HTTP/1.0 200 OK\r\nDate: Thu, 29 Jan 2009 03:55:24 GMT\r\nServer: Apache\r\nX-FB-Host: chi-write6\r\nLast-Modified: Wed, 28 Jan 2009 04:10:32 GMT\r\nETag: ziEyTl4q9GH04BR4jgkImd0GvSE\r\nP3P: CP=\"ALL DSP COR NID CUR OUR NOR\"\r\nConnection: close\r\nContent-Type: text/xml;charset=utf-8\r\n\r\n"
    end
    
    it "should parse out an etag" do
      Feedzirra::Feed.etag_from_header(@header).should == "ziEyTl4q9GH04BR4jgkImd0GvSE"
    end
    
    it "should parse out a last-modified date" do
      Feedzirra::Feed.last_modified_from_header(@header).should == "Wed, 28 Jan 2009 04:10:32 GMT"
    end
  end
  
  describe "fetching feeds" do
    before(:each) do
      @feed_url = "http://feeds.feedburner.com/PaulDixExplainsNothing"
      @feed_url2 = "http://feeds.feedburner.com/trottercashion"
    end
    
    describe "#fetch_raw" do
      it "should return raw xml when not passed a block" do
        Feedzirra::Feed.fetch_raw(@feed_url).should =~ /^#{Regexp.escape('<?xml version="1.0" encoding="UTF-8"?>')}/
      end
      
      it "should take multiple feed urls and return a hash of urls and responses" do
        results = Feedzirra::Feed.fetch_raw([@feed_url, @feed_url2])
        results.keys.should include(@feed_url)
        results.keys.should include(@feed_url2)
        results[@feed_url].should =~ /Paul Dix/
        results[@feed_url2].should =~ /Trotter Cashion/
      end
    end
    
    describe "#fetch_and_parse" do
    end
  end
end