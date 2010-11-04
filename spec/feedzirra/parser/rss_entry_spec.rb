# coding: utf-8
require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::RSSEntry do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on RSSEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @entry = Feedzirra::Parser::RSS.parse(sample_rss_feed).entries.first
  end
  
  it "should parse the title" do
    @entry.title.should == "Nokogiri’s Slop Feature"
  end
  
  it "should parse the url" do
    @entry.url.should == "http://tenderlovemaking.com/2008/12/04/nokogiris-slop-feature/"
  end
  
  it "should parse the author" do
    @entry.author.should == "Aaron Patterson"
  end
  
  it "should parse the content" do
    @entry.content.should == sample_rss_entry_content
  end
  
  it "should provide a summary" do
    @entry.summary.should == "Oops!  When I released nokogiri version 1.0.7, I totally forgot to talk about Nokogiri::Slop() feature that was added.  Why is it called \"slop\"?  It lets you sloppily explore documents.  Basically, it decorates your document with method_missing() that allows you to search your document via method calls.\nGiven this document:\n\ndoc = Nokogiri::Slop&#40;&#60;&#60;-eohtml&#41;\n&#60;html&#62;\n&#160; &#60;body&#62;\n&#160; [...]"
  end
  
  it "should parse the published date" do      
    @entry.published.to_s.should == "Thu Dec 04 17:17:49 UTC 2008"
  end

  it "should parse the categories" do
    @entry.categories.should == ['computadora', 'nokogiri', 'rails']
  end
  
  it "should parse the guid as id" do
    @entry.id.should == "http://tenderlovemaking.com/?p=198"
  end
end