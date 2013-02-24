require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::AtomFeedBurner do
  describe "#will_parse?" do
    it "should return true for a feedburner atom feed" do
      Feedzirra::Parser::AtomFeedBurner.should be_able_to_parse(sample_feedburner_atom_feed)
    end

    it "should return false for an rdf feed" do
      Feedzirra::Parser::AtomFeedBurner.should_not be_able_to_parse(sample_rdf_feed)
    end

    it "should return false for a regular atom feed" do
      Feedzirra::Parser::AtomFeedBurner.should_not be_able_to_parse(sample_atom_feed)
    end

    it "should return false for an rss feedburner feed" do
      Feedzirra::Parser::AtomFeedBurner.should_not be_able_to_parse(sample_rss_feed_burner_feed)
    end
  end

  describe "parsing" do
    before(:each) do
      @feed = Feedzirra::Parser::AtomFeedBurner.parse(sample_feedburner_atom_feed)
    end

    it "should parse the title" do
      @feed.title.should == "Paul Dix Explains Nothing"
    end

    it "should parse the description" do
      @feed.description.should == "Entrepreneurship, programming, software development, politics, NYC, and random thoughts."
    end

    it "should parse the url" do
      @feed.url.should == "http://www.pauldix.net/"
    end

    it "should parse the feed_url" do
      @feed.feed_url.should == "http://feeds.feedburner.com/PaulDixExplainsNothing"
    end

    it "should parse no hub urls" do
      @feed.hubs.count.should == 0
    end

    it "should parse hub urls" do
      feed_with_hub = Feedzirra::Parser::AtomFeedBurner.parse(load_sample("TypePadNews.xml"))
      feed_with_hub.hubs.count.should == 1
    end

    it "should parse entries" do
      @feed.entries.size.should == 5
    end
  end
end
