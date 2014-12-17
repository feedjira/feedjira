require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::RSS do
  describe "#will_parse?" do
    it "should return true for an RSS feed" do
      expect(Feedjira::Parser::RSS).to be_able_to_parse(sample_rss_feed)
    end

    # this is no longer true. combined rdf and rss into one
    # it "should return false for an rdf feed" do
    #   Feedjira::RSS.should_not be_able_to_parse(sample_rdf_feed)
    # end

    it "should return false for an atom feed" do
      expect(Feedjira::Parser::RSS).to_not be_able_to_parse(sample_atom_feed)
    end

    it "should return false for an rss feedburner feed" do
      expect(Feedjira::Parser::RSS).to_not be_able_to_parse(sample_rss_feed_burner_feed)
    end
  end

  describe "parsing" do
    before(:each) do
      @feed = Feedjira::Parser::RSS.parse(sample_rss_feed)
    end

    it "should parse the version" do
      expect(@feed.version).to eq "2.0"
    end

    it "should parse the title" do
      expect(@feed.title).to eq "Tender Lovemaking"
    end

    it "should parse the description" do
      expect(@feed.description).to eq "The act of making love, tenderly."
    end

    it "should parse the url" do
      expect(@feed.url).to eq "http://tenderlovemaking.com"
    end

    it "should parse the hub urls" do
      expect(@feed.hubs.count).to eq 1
      expect(@feed.hubs.first).to eq "http://pubsubhubbub.appspot.com/"
    end

    it "should provide an accessor for the feed_url" do
      expect(@feed).to respond_to :feed_url
      expect(@feed).to respond_to :feed_url=
    end

    it "should parse entries" do
      expect(@feed.entries.size).to eq 10
    end
  end
end
