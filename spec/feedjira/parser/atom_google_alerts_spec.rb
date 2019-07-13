require "spec_helper"

module Feedjira
  module Parser
    describe "#able_to_parse?" do
      it "should return true for a Google Alerts atom feed" do
        expect(AtomGoogleAlerts).to be_able_to_parse(sample_google_alerts_atom_feed)
      end

      it "should return false for an rdf feed" do
        expect(AtomGoogleAlerts).to_not be_able_to_parse(sample_rdf_feed)
      end

      it "should return false for a regular atom feed" do
        expect(AtomGoogleAlerts).to_not be_able_to_parse(sample_atom_feed)
      end

      it "should return false for a feedburner atom feed" do
        expect(AtomGoogleAlerts).to_not be_able_to_parse(sample_feedburner_atom_feed)
      end
    end

    describe "parsing" do
      before(:each) do
        @feed = AtomGoogleAlerts.parse(sample_google_alerts_atom_feed)
      end

      it "should parse the title" do
        expect(@feed.title).to eq "Google Alert - Slack"
      end

      it "should parse the descripton" do
        expect(@feed.description).to be_nil
      end

      it "should parse the url" do
        expect(@feed.url).to eq "https://www.google.com/alerts/feeds/04175468913983673025/4428013283581841004"
      end

      it "should parse the feed_url" do
        expect(@feed.feed_url).to eq "https://www.google.com/alerts/feeds/04175468913983673025/4428013283581841004"
      end

      it "should parse entries" do
        expect(@feed.entries.size).to eq 20
      end
    end

    describe "preprocessing" do
      it "retains markup in xhtml content" do
        AtomGoogleAlerts.preprocess_xml = true

        feed = AtomGoogleAlerts.parse sample_google_alerts_atom_feed
        entry = feed.entries.first

        expect(entry.content).to include("<b>Slack</b>")
      end
    end
  end
end
