require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::ITunesRSSItem do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on ITunesRssItem,
    # but this is actually how it should work. You would never just pass entry xml straight to the ITunesRssItem
    @item = Feedzirra::Parser::ITunesRSS.parse(sample_itunes_feed).entries.first
  end
  
  it "should parse the title" do
    @item.title.should == "Shake Shake Shake Your Spices"
  end
  
  it "should parse the author" do
    @item.itunes_author.should == "John Doe"
  end  

  it "should parse the subtitle" do
    @item.itunes_subtitle.should == "A short primer on table spices"
  end  

  it "should parse the summary" do
    @item.itunes_summary.should == "This week we talk about salt and pepper shakers, comparing and contrasting pour rates, construction materials, and overall aesthetics. Come and join the party!"
  end  

  it "should parse the enclosure" do
    @item.enclosure_length.should == "8727310"
    @item.enclosure_type.should == "audio/x-m4a"
    @item.enclosure_url.should == "http://example.com/podcasts/everything/AllAboutEverythingEpisode3.m4a"
  end  

  it "should parse the guid" do
    @item.guid.should == "http://example.com/podcasts/archive/aae20050615.m4a"
  end  

  it "should parse the published date" do
    @item.published.should == Time.parse_safely("Wed Jun 15 19:00:00 UTC 2005")
  end  

  it "should parse the duration" do
    @item.itunes_duration.should == "7:04"
  end  

  it "should parse the keywords" do
    @item.itunes_keywords.should == "salt, pepper, shaker, exciting"
  end  

end