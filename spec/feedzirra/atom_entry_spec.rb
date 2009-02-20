require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::AtomEntry do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on AtomEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @entry = Feedzirra::Atom.parse(sample_atom_feed).entries.first
  end
  
  it "should parse the title" do
    @entry.title.should == "AWS Job: Architect & Designer Position in Turkey"
  end
  
  it "should parse the url" do
    @entry.url.should == "http://aws.typepad.com/aws/2009/01/aws-job-architect-designer-position-in-turkey.html"
  end
  
  it "should parse the author" do
    @entry.author.should == "AWS Editor"
  end
  
  it "should parse the content" do
    @entry.content.should == sample_atom_entry_content
  end
  
  it "should provide a summary" do
    @entry.summary.should == "Late last year an entrepreneur from Turkey visited me at Amazon HQ in Seattle. We talked about his plans to use AWS as part of his new social video portal startup. I won't spill any beans before he's ready to..."
  end
  
  it "should parse the published date" do
    @entry.published.to_s.should == "Fri Jan 16 18:21:00 UTC 2009"
  end

  it "should parse the categories" do
    @entry.categories.should == ['Turkey', 'Seattle']
  end
end