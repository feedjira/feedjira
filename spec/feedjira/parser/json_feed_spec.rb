require "spec_helper"

module Feedjira
  module Parser
    describe ".able_to_parse?" do
      it "should return true for a JSON feed" do
        expect(JSONFeed).to be_able_to_parse(sample_json_feed)
      end

      it "should return false for an RSS feed" do
        expect(JSONFeed).to_not be_able_to_parse(sample_rss_feed)
      end

      it "should return false for an Atom feed" do
        expect(JSONFeed).to_not be_able_to_parse(sample_atom_feed)
      end
    end

    describe "parsing" do
      before(:each) do
        @feed = JSONFeed.parse(sample_json_feed)
      end

      it "should parse the version" do
        expect(@feed.version).to eq "https://jsonfeed.org/version/1"
      end

      it "should parse the title" do
        expect(@feed.title).to eq "inessential.com"
      end

      it "should parse the url" do
        expect(@feed.url).to eq "http://inessential.com/"
      end

      it "should parse the feed_url" do
        expect(@feed.feed_url).to eq "http://inessential.com/feed.json"
      end

      it "should parse the description" do
        expect(@feed.description).to eq "Brent Simmons’s weblog."
      end

      it "should parse expired and return default (nil)" do
        expect(@feed.expired).to be nil
      end

      it "should parse entries" do
        expect(@feed.entries.size).to eq 20
      end
    end
  end
end
