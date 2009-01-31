require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::Feed do
  describe "#parse" do # many of these tests are redundant with the specific feed type tests, but I put them here for completeness
    context "when there's an available parser" do
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
    
    context "when there's no available parser" do
      it "raises Feedzirra::NoParserAvailable" do
        proc {
          Feedzirra::Feed.parse("I'm an invalid feed")
        }.should raise_error(Feedzirra::NoParserAvailable)
      end      
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
    it "should prioritize added feed types over the built in ones" do
      feed_text = "Atom asdf"
      Feedzirra::Atom.should be_able_to_parse(feed_text)
      new_feed_type = Class.new do
        def self.able_to_parse?(val)
          true
        end
      end
      new_feed_type.should be_able_to_parse(feed_text)
      Feedzirra::Feed.add_feed_class(new_feed_type)
      Feedzirra::Feed.determine_feed_parser_for_xml(feed_text).should == new_feed_type
      
      # this is a hack so that this doesn't break the rest of the tests
      Feedzirra::Feed.feed_classes.reject! {|o| o == new_feed_type }
    end
  end
  
  describe "header parsing" do
    before(:each) do
      @header = "HTTP/1.0 200 OK\r\nDate: Thu, 29 Jan 2009 03:55:24 GMT\r\nServer: Apache\r\nX-FB-Host: chi-write6\r\nLast-Modified: Wed, 28 Jan 2009 04:10:32 GMT\r\nETag: ziEyTl4q9GH04BR4jgkImd0GvSE\r\nP3P: CP=\"ALL DSP COR NID CUR OUR NOR\"\r\nConnection: close\r\nContent-Type: text/xml;charset=utf-8\r\n\r\n"
    end
    
    it "should parse out an etag" do
      Feedzirra::Feed.etag_from_header(@header).should == "ziEyTl4q9GH04BR4jgkImd0GvSE"
    end
    
    it "should return nil if there is no etag in header" do
      Feedzirra::Feed.etag_from_header("foo").should be_nil
    end
    
    it "should parse out a last-modified date" do
      Feedzirra::Feed.last_modified_from_header(@header).should == Time.parse("Wed, 28 Jan 2009 04:10:32 GMT")
    end
    
    it "should return nil if there is no last-modified in header" do
      Feedzirra::Feed.last_modified_from_header("foo").should be_nil
    end
  end
  
  describe "fetching feeds" do
    before(:each) do
      @paul_feed_url = "http://feeds.feedburner.com/PaulDixExplainsNothing"
      @trotter_feed_url = "http://feeds.feedburner.com/trottercashion"
    end
    
    describe "#fetch_raw" do
      it "should take :user_agent as an option"
      it "should take :if_modified_since as an option"
      it "should take :if_none_match as an option"
      it "should take an optional on_success lambda"
      it "should take an optional on_failure lambda"
      
      it "should return raw xml" do
        Feedzirra::Feed.fetch_raw(@paul_feed_url).should =~ /^#{Regexp.escape('<?xml version="1.0" encoding="UTF-8"?>')}/
      end
      
      it "should take multiple feed urls and return a hash of urls and response xml" do
        results = Feedzirra::Feed.fetch_raw([@paul_feed_url, @trotter_feed_url])
        results.keys.should include(@paul_feed_url)
        results.keys.should include(@trotter_feed_url)
        results[@paul_feed_url].should =~ /Paul Dix/
        results[@trotter_feed_url].should =~ /Trotter Cashion/
      end
    end
    
    describe "#fetch_and_parse" do
      it "should return a feed object for a single url" do
        feed = Feedzirra::Feed.fetch_and_parse(@paul_feed_url)
        feed.title.should == "Paul Dix Explains Nothing"
      end
      
      it "should set the feed_url to the new url if redirected" do
        feed = Feedzirra::Feed.fetch_and_parse("http://tinyurl.com/tenderlovemaking")
        feed.feed_url.should == "http://tenderlovemaking.com/feed/"
      end
      
      it "should set the feed_url for an rdf feed" do
        feed = Feedzirra::Feed.fetch_and_parse("http://www.avibryant.com/rss.xml")
        feed.feed_url.should == "http://www.avibryant.com/rss.xml"
      end
      
      it "should set the feed_url for an rss feed" do
        feed = Feedzirra::Feed.fetch_and_parse("http://tenderlovemaking.com/feed/")
        feed.feed_url.should == "http://tenderlovemaking.com/feed/"
      end
      
      it "should return a hash of feed objects with the passed in feed_url for the key and parsed feed for the value for multiple feeds" do
        feeds = Feedzirra::Feed.fetch_and_parse([@paul_feed_url, @trotter_feed_url])
        feeds.size.should == 2
        feeds[@paul_feed_url].feed_url.should == @paul_feed_url
        feeds[@trotter_feed_url].feed_url.should == @trotter_feed_url
      end
      
      it "should yeild the url and feed object to a :on_success lambda" do
        successful_call_mock = mock("successful_call_mock")
        successful_call_mock.should_receive(:call)
        Feedzirra::Feed.fetch_and_parse(@paul_feed_url, :on_success => lambda { |feed_url, feed|
          feed_url.should == @paul_feed_url
          feed.class.should == Feedzirra::AtomFeedBurner
          successful_call_mock.call})
      end
      
      it "should yield the url, response_code, response_header, and response_body to a :on_failure lambda" do
        failure_call_mock = mock("failure_call_mock")
        failure_call_mock.should_receive(:call)
        fail_url = "http://localhost"
        Feedzirra::Feed.fetch_and_parse(fail_url, :on_failure => lambda {|feed_url, response_code, response_header, response_body|
          feed_url.should == fail_url
          response_code.should == 0
          response_header.should == ""
          response_body.should == ""
          failure_call_mock.call})
      end
      
      it "should return a not modified status for a feed with a :if_modified_since is past its last update" do
        Feedzirra::Feed.fetch_and_parse(@paul_feed_url, :if_modified_since => Time.now).should == 304
      end
      
      it "should set the etag from the header" # do
       #        Feedzirra::Feed.fetch_and_parse(@paul_feed_url).etag.should_not == ""
       #      end
      
      it "should set the last_modified from the header" # do
       #        Feedzirra::Feed.fetch_and_parse(@paul_feed_url).last_modified.should.class == Time
       #      end
    end

    describe "#update" do
      it "should update and return a single feed object" do
        feed = Feedzirra::Feed.fetch_and_parse(@paul_feed_url)
        feed.entries.delete_at(0)
        feed.last_modified = nil
        feed.etag = nil
        updated_feed = Feedzirra::Feed.update(feed)
        updated_feed.new_entries.size.should == 1
        updated_feed.should have_new_entries
      end

      it "should update a collection of feed objects"
      it "should return the feed objects even when not updated"
    end
  end
end