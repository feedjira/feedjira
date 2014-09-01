# coding: utf-8
require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::RSSEntry do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on RSSEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @entry = Feedjira::Parser::RSS.parse(sample_rss_feed).entries.first
    Feedjira::Feed.add_common_feed_entry_element("wfw:commentRss", :as => :comment_rss)
  end

  after(:each) do
    # We change the title in one or more specs to test []=
    if @entry.title != "Nokogiri’s Slop Feature"
      @entry.title = Feedjira::Parser::RSS.parse(sample_rss_feed).entries.first.title
    end
  end

  it "should parse the title" do
    expect(@entry.title).to eq "Nokogiri’s Slop Feature"
  end

  it "should parse the url" do
    expect(@entry.url).to eq "http://tenderlovemaking.com/2008/12/04/nokogiris-slop-feature/"
  end

  it "should parse the author" do
    expect(@entry.author).to eq "Aaron Patterson"
  end

  it "should parse the content" do
    expect(@entry.content).to eq sample_rss_entry_content
  end

  it "should provide a summary" do
    expect(@entry.summary).to eq "Oops!  When I released nokogiri version 1.0.7, I totally forgot to talk about Nokogiri::Slop() feature that was added.  Why is it called \"slop\"?  It lets you sloppily explore documents.  Basically, it decorates your document with method_missing() that allows you to search your document via method calls.\nGiven this document:\n\ndoc = Nokogiri::Slop&#40;&#60;&#60;-eohtml&#41;\n&#60;html&#62;\n&#160; &#60;body&#62;\n&#160; [...]"
  end

  it "should parse the published date" do
    expect(@entry.published).to eq Time.parse_safely("Thu Dec 04 17:17:49 UTC 2008")
  end

  it "should parse the categories" do
    expect(@entry.categories).to eq ['computadora', 'nokogiri', 'rails']
  end

  it "should parse the guid as id" do
    expect(@entry.id).to eq "http://tenderlovemaking.com/?p=198"
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
    expect(all_fields.sort).to eq ["author", "categories", "comment_rss", "content", "entry_id", "published", "summary", "title", "url"]
    expect(title_value).to eq "Nokogiri’s Slop Feature"
  end

  it "should support checking if a field exists in the entry" do
    expect(@entry).to include 'title'
    expect(@entry).to include 'author'
  end

  it "should allow access to fields with hash syntax" do
    expect(@entry['title']).to eq "Nokogiri’s Slop Feature"
    expect(@entry['author']).to eq "Aaron Patterson"
  end

  it "should allow setting field values with hash syntax" do
    @entry['title'] = "Foobar"
    expect(@entry.title).to eq "Foobar"
  end
end
