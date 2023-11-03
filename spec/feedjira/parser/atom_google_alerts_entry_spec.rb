# frozen_string_literal: true

require "spec_helper"

describe Feedjira::Parser::AtomGoogleAlertsEntry do
  before do
    feed = Feedjira::Parser::AtomGoogleAlerts.parse sample_google_alerts_atom_feed
    @entry = feed.entries.first
  end

  it "parses the title" do
    expect(@entry.title).to eq "Report offers Prediction of Automotive Slack Market by Top key players like Haldex, Meritor, Bendix ..."
    expect(@entry.raw_title).to eq "Report offers Prediction of Automotive <b>Slack</b> Market by Top key players like Haldex, Meritor, Bendix ..."
    expect(@entry.title_type).to eq "html"
  end

  it "parses the url out of the params when the host is google" do
    url = "https://www.exampoo.com"
    entry = described_class.new(url: "https://www.google.com/url?url=#{url}")

    expect(entry.url).to eq url
  end

  it "returns nil when the url is not present" do
    entry = described_class.new

    expect(entry.url).to be_nil
  end

  it "returns nil when the host is not google" do
    entry = described_class.new(url: "https://www.exampoo.com")

    expect(entry.url).to be_nil
  end

  it "parses the content" do
    expect(@entry.content).to eq "Automotive <b>Slack</b> Market reports provides a comprehensive overview of the global market size and share. It provides strategists, marketers and senior&nbsp;..."
  end

  it "parses the published date" do
    published = Feedjira::Util::ParseTime.call "2019-07-10T11:53:37Z"
    expect(@entry.published).to eq published
  end

  it "parses the updated date" do
    updated = Feedjira::Util::ParseTime.call "2019-07-10T11:53:37Z"
    expect(@entry.updated).to eq updated
  end
end
