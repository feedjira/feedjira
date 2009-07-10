require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::Atom do
  describe "#will_parse?" do
    it "should return true for an atom feed" do
      Feedzirra::Parser::Atom.should be_able_to_parse(sample_atom_feed)
    end
    
    it "should return false for an rdf feed" do
      Feedzirra::Parser::Atom.should_not be_able_to_parse(sample_rdf_feed)
    end
  end
  
  describe "parsing" do
    before(:each) do
      @feed = Feedzirra::Parser::Atom.parse(sample_atom_feed)
    end
    
    it "should parse the title" do
      @feed.title.should == "Amazon Web Services Blog"
    end
    
    it "should parse the url" do
      @feed.url.should == "http://aws.typepad.com/aws/"
    end
    
    it "should parse the url even when it doesn't have the type='text/html' attribute" do
      Feedzirra::Parser::Atom.parse(load_sample("atom_with_link_tag_for_url_unmarked.xml")).url.should == "http://www.innoq.com/planet/"
    end
    
    it "should parse the feed_url even when it doesn't have the type='application/atom+xml' attribute" do
      Feedzirra::Parser::Atom.parse(load_sample("atom_with_link_tag_for_url_unmarked.xml")).feed_url.should == "http://www.innoq.com/planet/atom.xml"
    end
    
    it "should parse the feed_url" do
      @feed.feed_url.should == "http://aws.typepad.com/aws/atom.xml"
    end
    
    it "should parse entries" do
      @feed.entries.size.should == 10
    end
  end
end