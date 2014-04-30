require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::AtomFeedBurner do
  describe "#will_parse?" do
    it "should return true for a feedburner atom feed" do
      Feedjira::Parser::AtomFeedBurner.should be_able_to_parse(sample_feedburner_atom_feed)
    end

    it "should return false for an rdf feed" do
      Feedjira::Parser::AtomFeedBurner.should_not be_able_to_parse(sample_rdf_feed)
    end

    it "should return false for a regular atom feed" do
      Feedjira::Parser::AtomFeedBurner.should_not be_able_to_parse(sample_atom_feed)
    end

    it "should return false for an rss feedburner feed" do
      Feedjira::Parser::AtomFeedBurner.should_not be_able_to_parse(sample_rss_feed_burner_feed)
    end
  end

  describe "parsing" do
    before(:each) do
      @feed = Feedjira::Parser::AtomFeedBurner.parse(sample_feedburner_atom_feed)
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
      feed_with_hub = Feedjira::Parser::AtomFeedBurner.parse(load_sample("TypePadNews.xml"))
      feed_with_hub.hubs.count.should == 1
    end

    it "should parse entries" do
      @feed.entries.size.should == 5
    end
  end

  describe "preprocessing" do
    it "retains markup in xhtml content" do
      Feedjira::Parser::AtomFeedBurner.preprocess_xml = true

      feed = Feedjira::Parser::AtomFeedBurner.parse sample_feed_burner_atom_xhtml_feed
      entry = feed.entries.first

      entry.content.should match /\A\<p/
    end
  end
end
