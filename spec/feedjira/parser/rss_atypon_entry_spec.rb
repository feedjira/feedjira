# coding: utf-8
require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::RSSAtyponEntry do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on RSSEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @entry = Feedjira::Parser::RSSAtypon.parse(sample_atypon_rss_feed).entries.first
  end

  after(:each) do
    # We change the title in one or more specs to test []=
    if @entry.title != "Effect of Systems Change and Use of Electronic Health Records on Quit Rates Among Tobacco Users in a Public Hospital System"
      @entry.title = Feedjira::Parser::RSSAtypon.parse(sample_atypon_rss_feed).entries.first.title
    end
  end

  it "should parse the title" do
    expect(@entry.title).to eq "Effect of Systems Change and Use of Electronic Health Records on Quit Rates Among Tobacco Users in a Public Hospital System"
  end

  it "should parse the original url" do
    expect(@entry.url).to eq "http://ajph.aphapublications.org/doi/abs/10.2105/AJPH.2014.302274?af=R"
  end

  it "should parse the author" do
    expect(@entry.author).to eq "Sarah Moody-Thomas"
  end

  it "should parse the content" do
    expect(@entry.content).to eq "American Journal of Public Health, <a href=\"/toc/ajph/105/S2\">Volume 105, Issue S2</a>, Page e1-e7, April 2015. <br/>"
  end

  it "should provide a summary" do
    expect(@entry.summary).to eq "American Journal of Public Health, Volume 105, Issue S2, Page e1-e7, April 2015. <br/>"
  end

  it "should parse the published date" do
    expect(@entry.published).to eq Time.parse_safely("Fri, 06 Mar 2015 21:09:13 GMT")
  end

  it "should parse the categories" do
    expect(@entry.categories).to eq ["A", "B"]
  end

  it "should parse the guid as id" do
    expect(@entry.id).to eq "doi:10.2105/AJPH.2014.302274"
  end

  it "should support each" do
    expect(@entry).to respond_to :each
  end

  it "should be able to list out all fields with each" do
    all_fields = []
    title_value = ''
    @entry.each do |field, value|
      all_fields << field
      title_value = value if field == 'title'
    end
    expect(all_fields.sort).to eq ["author", "categories", "content", "entry_id", "published", "summary", "title", "url"]
    expect(title_value).to eq "Effect of Systems Change and Use of Electronic Health Records on Quit Rates Among Tobacco Users in a Public Hospital System"
  end

  it "should support checking if a field exists in the entry" do
    expect(@entry).to include 'author'
    expect(@entry).to include 'title'
  end

  it "should allow access to fields with hash syntax" do
    expect(@entry['author']).to eq "Sarah Moody-Thomas"
    expect(@entry['title']).to eq "Effect of Systems Change and Use of Electronic Health Records on Quit Rates Among Tobacco Users in a Public Hospital System"
  end

  it "should allow setting field values with hash syntax" do
    @entry['title'] = "Foobar"
    expect(@entry.title).to eq "Foobar"
  end
end
