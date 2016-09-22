require 'spec_helper'

describe Feedjira::Parser::ITunesRSSItem do
  before(:each) do
    # I don't really like doing it this way because these unit test should only
    # rely on ITunesRssItem, but this is actually how it should work. You would
    # never just pass entry xml straight to the ITunesRssItem
    @item = Feedjira::Parser::ITunesRSS.parse(sample_itunes_feed).entries.first
  end

  it 'should parse the title' do
    expect(@item.title).to eq 'Shake Shake Shake Your Spices'
  end

  it 'should parse the author' do
    expect(@item.itunes_author).to eq 'John Doe'
  end

  it 'should parse the subtitle' do
    expect(@item.itunes_subtitle).to eq 'A short primer on table spices'
  end

  it 'should parse the summary' do
    summary = 'This week we talk about salt and pepper shakers, comparing and contrasting pour rates, construction materials, and overall aesthetics. Come and join the party!' # rubocop:disable Metrics/LineLength
    expect(@item.itunes_summary).to eq summary
  end

  it 'should parse the enclosure' do
    expect(@item.enclosure_length).to eq '8727310'
    expect(@item.enclosure_type).to eq 'audio/x-m4a'
    expect(@item.enclosure_url).to eq 'http://example.com/podcasts/everything/AllAboutEverythingEpisode3.m4a'
  end

  it 'should parse the guid as id' do
    expect(@item.id).to eq 'http://example.com/podcasts/archive/aae20050615.m4a'
  end

  it 'should parse the published date' do
    published = Time.parse_safely 'Wed Jun 15 19:00:00 UTC 2005'
    expect(@item.published).to eq published
  end

  it 'should parse the duration' do
    expect(@item.itunes_duration).to eq '7:04'
  end

  it 'should parse the keywords' do
    expect(@item.itunes_keywords).to eq 'salt, pepper, shaker, exciting'
  end

  it 'should parse the image' do
    expect(@item.itunes_image).to eq 'http://example.com/podcasts/everything/AllAboutEverything.jpg'
  end

  it 'should parse the order' do
    expect(@item.itunes_order).to eq '12'
  end

  it 'should parse the closed captioned flag' do
    expect(@item.itunes_closed_captioned).to eq 'yes'
  end

  it 'should parse the encoded content' do
    content = '<p><strong>TOPIC</strong>: Gooseneck Options</p>'
    expect(@item.content).to eq content
  end
end
