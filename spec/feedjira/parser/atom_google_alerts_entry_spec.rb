require "spec_helper"

describe Feedjira::Parser::AtomGoogleAlertsEntry do
  before(:each) do
    feed = Feedjira::Parser::AtomGoogleAlerts.parse sample_google_alerts_atom_feed
    @entry = feed.entries.first
  end

  it "should parse the title" do
    expect(@entry.title).to eq "Report offers Prediction of Automotive Slack Market by Top key players like Haldex, Meritor, Bendix ..." # rubocop:disable Metrics/LineLength
    expect(@entry.raw_title).to eq "Report offers Prediction of Automotive <b>Slack</b> Market by Top key players like Haldex, Meritor, Bendix ..." # rubocop:disable Metrics/LineLength
    expect(@entry.title_type).to eq "html"
  end

  it "should parse the url" do
    expect(@entry.url).to eq "https://www.aglobalmarketresearch.com/report-offers-prediction-of-automotive-slack-market-by-top-key-players-like-haldex-meritor-bendix-mei-wabco-accuride-stemco-tbk-febi-aydinsan/" # rubocop:disable Metrics/LineLength
  end

  it "should parse the content" do
    expect(@entry.content).to eq "Automotive <b>Slack</b> Market reports provides a comprehensive overview of the global market size and share. It provides strategists, marketers and senior&nbsp;..." # rubocop:disable Metrics/LineLength
  end

  it "should parse the published date" do
    published = Time.parse_safely "2019-07-10T11:53:37Z"
    expect(@entry.published).to eq published
  end

  it "should parse the updated date" do
    updated = Time.parse_safely "2019-07-10T11:53:37Z"
    expect(@entry.updated).to eq updated
  end
end
