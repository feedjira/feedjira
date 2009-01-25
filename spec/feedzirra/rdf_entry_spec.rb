require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::RDFEntry do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on AtomEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @entry = Feedzirra::RDF.parse(sample_rdf_feed).entries.first
  end
  
  it "should parse the title" do
    @entry.title.should == "Chrome, V8 and Strongtalk"
  end
  
  it "should parse the url" do
    @entry.url.should == "http://www.avibryant.com/2008/09/chrome-v8-and-s.html"
  end
  
  it "should parse the author" do
    @entry.author.should == "Avi"
  end
  
  it "should parse the content" do
    @entry.content.should == sample_rdf_entry_content
  end
  
  it "should provide a summary" do
    @entry.summary.should == "There's lots to like about Google's new web browser, Chrome, which was released today. When I read the awesome comic strip introduction yesterday, however, the thing that stood out most for me was in very small type: the name Lars..."
  end
  
  it "should parse the published date" do
    @entry.published.to_s.should == "Tue Sep 02 19:50:07 UTC 2008"
  end
end