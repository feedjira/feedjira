require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::RDF do
  describe "#will_parse?" do
    it "should return true for an rdf feed" do
      Feedzirra::RDF.will_parse?(sample_rdf_feed).should be_true
    end
    
    it "should return false for an atom feed" do
      Feedzirra::RDF.will_parse?(sample_atom_feed).should be_false
    end
  end
  
  describe "parsing" do
    before(:each) do
      @feed = Feedzirra::RDF.parse(sample_rdf_feed)
    end
    
    it "should parse the title" do
      @feed.title.should == "HREF Considered Harmful"
    end
    
    it "should parse the url" do
      @feed.url.should == "http://www.avibryant.com/"
    end
    
    # rdf doesn't actually specify the feed_url. This should be set in the fetcher.
    # this is just a reminder that I need to do that later.
    it "should parse the feed_url"
    
    it "should parse entries" do
      @feed.entries.size.should == 10
    end    
  end
end