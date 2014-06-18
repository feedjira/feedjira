# coding: utf-8
require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::RSSFeedBurnerEntry do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on RSSEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @entry = Feedjira::Parser::RSSFeedBurner.parse(sample_rss_feed_burner_feed).entries.first
  end

  after(:each) do
    # We change the title in one or more specs to test []=
    if @entry.title != "Angie’s List Sets Price Range IPO At $11 To $13 Per Share; Valued At Over $600M"
      @entry.title = Feedjira::Parser::RSS.parse(sample_rss_feed_burner_feed).entries.first.title
    end
  end

  it "should parse the title" do
    @entry.title.should == "Angie’s List Sets Price Range IPO At $11 To $13 Per Share; Valued At Over $600M"
  end

  it "should parse the original url" do
    @entry.url.should == "http://techcrunch.com/2011/11/02/angies-list-prices-ipo-at-11-to-13-per-share-valued-at-over-600m/"
  end

  it "should parse the author" do
    @entry.author.should == "Leena Rao"
  end

  it "should parse the content" do
    @entry.content.should == sample_rss_feed_burner_entry_content
  end

  it "should parse the image" do
    @entry.image.should == "http://tctechcrunch2011.files.wordpress.com/2011/11/angies-list.jpeg?w=150"
  end

  it "should provide a summary" do
    @entry.summary.should == sample_rss_feed_burner_entry_description
  end

  it "should parse the published date" do
    @entry.published.should == Time.parse_safely("Wed Nov 02 17:25:27 UTC 2011")
  end

  it "should parse the categories" do
    @entry.categories.should == ["TC", "angie\\'s list"]
  end

  it "should parse the guid as id" do
    @entry.id.should == "http://techcrunch.com/?p=446154"
  end

  it "should support each" do
    @entry.respond_to? :each
  end

  it "should be able to list out all fields with each" do
    all_fields = []
    @entry.each do |field, value|
      all_fields << field
    end
    all_fields.sort == ['author', 'categories', 'content', 'id', 'published', 'summary', 'title', 'url']
  end

  it "should be able to list out all values with each" do
    title_value = ''
    @entry.each do |field, value|
      title_value = value if field == 'title'
    end
    title_value.should == "Angie’s List Sets Price Range IPO At $11 To $13 Per Share; Valued At Over $600M"
  end

  it "should support checking if a field exists in the entry" do
    @entry.include?('title') && @entry.include?('author')
  end

  it "should allow access to fields with hash syntax" do
    @entry['title'] == @entry.title
    @entry['title'].should == "Angie’s List Sets Price Range IPO At $11 To $13 Per Share; Valued At Over $600M"
    @entry['author'] == @entry.author
    @entry['author'].should == "Leena Rao"
  end

  it "should allow setting field values with hash syntax" do
    @entry['title'] = "Foobar"
    @entry.title.should == "Foobar"
  end
end
