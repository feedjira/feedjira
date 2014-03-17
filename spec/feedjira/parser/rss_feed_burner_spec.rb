require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::RSSFeedBurner do
  describe "#will_parse?" do
    it "should return true for a feedburner rss feed" do
      Feedjira::Parser::RSSFeedBurner.should be_able_to_parse(sample_rss_feed_burner_feed)
    end

    it "should return false for a regular RSS feed" do
       Feedjira::Parser::RSSFeedBurner.should_not be_able_to_parse(sample_rss_feed)
     end

    it "should return false for a feedburner atom feed" do
      Feedjira::Parser::RSSFeedBurner.should_not be_able_to_parse(sample_feedburner_atom_feed)
    end

    it "should return false for an rdf feed" do
      Feedjira::Parser::RSSFeedBurner.should_not be_able_to_parse(sample_rdf_feed)
    end

    it "should return false for a regular atom feed" do
      Feedjira::Parser::RSSFeedBurner.should_not be_able_to_parse(sample_atom_feed)
    end
  end

  describe "parsing" do
    before(:each) do
      @feed = Feedjira::Parser::RSSFeedBurner.parse(sample_rss_feed_burner_feed)
    end

    it "should parse the title" do
      @feed.title.should == "TechCrunch"
    end

    it "should parse the description" do
      @feed.description.should == "TechCrunch is a group-edited blog that profiles the companies, products and events defining and transforming the new web."
    end

    it "should parse the url" do
      @feed.url.should == "http://techcrunch.com"
    end

    it "should parse the hub urls" do
      @feed.hubs.count.should == 2
      @feed.hubs.first.should == "http://pubsubhubbub.appspot.com/"
    end

    it "should provide an accessor for the feed_url" do
      @feed.respond_to?(:feed_url).should == true
      @feed.respond_to?(:feed_url=).should == true
    end

    it "should parse entries" do
      @feed.entries.size.should == 20
    end
  end
end
