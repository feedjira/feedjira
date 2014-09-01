require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::RSSFeedBurner do
  describe "#will_parse?" do
    it "should return true for a feedburner rss feed" do
      expect(Feedjira::Parser::RSSFeedBurner).to be_able_to_parse(sample_rss_feed_burner_feed)
    end

    it "should return false for a regular RSS feed" do
       expect(Feedjira::Parser::RSSFeedBurner).to_not be_able_to_parse(sample_rss_feed)
     end

    it "should return false for a feedburner atom feed" do
      expect(Feedjira::Parser::RSSFeedBurner).to_not be_able_to_parse(sample_feedburner_atom_feed)
    end

    it "should return false for an rdf feed" do
      expect(Feedjira::Parser::RSSFeedBurner).to_not be_able_to_parse(sample_rdf_feed)
    end

    it "should return false for a regular atom feed" do
      expect(Feedjira::Parser::RSSFeedBurner).to_not be_able_to_parse(sample_atom_feed)
    end
  end

  describe "parsing" do
    before(:each) do
      @feed = Feedjira::Parser::RSSFeedBurner.parse(sample_rss_feed_burner_feed)
    end

    it "should parse the title" do
      expect(@feed.title).to eq "TechCrunch"
    end

    it "should parse the description" do
      expect(@feed.description).to eq "TechCrunch is a group-edited blog that profiles the companies, products and events defining and transforming the new web."
    end

    it "should parse the url" do
      expect(@feed.url).to eq "http://techcrunch.com"
    end

    it "should parse the hub urls" do
      expect(@feed.hubs.count).to eq 2
      expect(@feed.hubs.first).to eq "http://pubsubhubbub.appspot.com/"
    end

    it "should provide an accessor for the feed_url" do
      expect(@feed).to respond_to :feed_url
      expect(@feed).to respond_to :feed_url=
    end

    it "should parse entries" do
      expect(@feed.entries.size).to eq 20
    end
  end
end
