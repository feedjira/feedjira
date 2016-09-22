require 'spec_helper'

describe Feedjira::Parser::ITunesRSSOwner do
  before(:each) do
    # I don't really like doing it this way because these unit test should only
    # rely on RSSEntry, but this is actually how it should work. You would
    # never just pass entry xml straight to the ITunesRssOwner
    feed = Feedjira::Parser::ITunesRSS.parse sample_itunes_feed
    @owner = feed.itunes_owners.first
  end

  it 'should parse the name' do
    expect(@owner.name).to eq 'John Doe'
  end

  it 'should parse the email' do
    expect(@owner.email).to eq 'john.doe@example.com'
  end
end
