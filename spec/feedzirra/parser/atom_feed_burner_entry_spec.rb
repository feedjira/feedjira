require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::AtomFeedBurnerEntry do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on AtomEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @entry = Feedzirra::Parser::AtomFeedBurner.parse(sample_feedburner_atom_feed).entries.first
  end
  
  it "should parse the title" do
    @entry.title.should == "Making a Ruby C library even faster"
  end
  
  it "should be able to fetch a url via the 'alternate' rel if no origLink exists" do
    entry = Feedzirra::Parser::AtomFeedBurner.parse(File.read("#{File.dirname(__FILE__)}/../../sample_feeds/PaulDixExplainsNothingAlternate.xml")).entries.first
    entry.url.should == 'http://feeds.feedburner.com/~r/PaulDixExplainsNothing/~3/519925023/making-a-ruby-c-library-even-faster.html'
  end

  it "should parse the url" do
    @entry.url.should == "http://www.pauldix.net/2009/01/making-a-ruby-c-library-even-faster.html"
  end
  
  it "should parse the url when there is no alternate" do
    entry = Feedzirra::Parser::AtomFeedBurner.parse(File.read("#{File.dirname(__FILE__)}/../../sample_feeds/FeedBurnerUrlNoAlternate.xml")).entries.first
    entry.url.should == 'http://example.com/QQQQ.html'
  end

  it "should parse the author" do
    @entry.author.should == "Paul Dix"
  end
  
  it "should parse the content" do
    @entry.content.should == sample_feedburner_atom_entry_content
  end
  
  it "should provide a summary" do
    @entry.summary.should == "Last week I released the first version of a SAX based XML parsing library called SAX-Machine. It uses Nokogiri, which uses libxml, so it's pretty fast. However, I felt that it could be even faster. The only question was how..."
  end
  
  it "should parse the published date" do
    @entry.published.should == Time.parse_safely("Thu Jan 22 15:50:22 UTC 2009")
  end

  it "should parse the categories" do
    @entry.categories.should == ['Ruby', 'Another Category']
  end
end