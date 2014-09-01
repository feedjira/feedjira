require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::AtomFeedBurner do
  describe "#will_parse?" do
    it "should return true for a feedburner atom feed" do
      expect(Feedjira::Parser::AtomFeedBurner).to be_able_to_parse(sample_feedburner_atom_feed)
    end

    it "should return false for an rdf feed" do
      expect(Feedjira::Parser::AtomFeedBurner).to_not be_able_to_parse(sample_rdf_feed)
    end

    it "should return false for a regular atom feed" do
      expect(Feedjira::Parser::AtomFeedBurner).to_not be_able_to_parse(sample_atom_feed)
    end

    it "should return false for an rss feedburner feed" do
      expect(Feedjira::Parser::AtomFeedBurner).to_not be_able_to_parse(sample_rss_feed_burner_feed)
    end
  end

  describe "parsing" do
    before(:each) do
      @feed = Feedjira::Parser::AtomFeedBurner.parse(sample_feedburner_atom_feed)
    end

    it "should parse the title" do
      expect(@feed.title).to eq "Paul Dix Explains Nothing"
    end

    it "should parse the description" do
      expect(@feed.description).to eq "Entrepreneurship, programming, software development, politics, NYC, and random thoughts."
    end

    it "should parse the url" do
      expect(@feed.url).to eq "http://www.pauldix.net/"
    end

    it "should parse the feed_url" do
      expect(@feed.feed_url).to eq "http://feeds.feedburner.com/PaulDixExplainsNothing"
    end

    it "should parse no hub urls" do
      expect(@feed.hubs.count).to eq 0
    end

    it "should parse hub urls" do
      feed_with_hub = Feedjira::Parser::AtomFeedBurner.parse(load_sample("TypePadNews.xml"))
      expect(feed_with_hub.hubs.count).to eq 1
    end

    it "should parse entries" do
      expect(@feed.entries.size).to eq 5
    end
  end

  describe "preprocessing" do
    it "retains markup in xhtml content" do
      Feedjira::Parser::AtomFeedBurner.preprocess_xml = true

      feed = Feedjira::Parser::AtomFeedBurner.parse sample_feed_burner_atom_xhtml_feed
      entry = feed.entries.first

      expect(entry.content).to match /\A\<p/
    end
  end
end
