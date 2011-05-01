require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::AtomEntry do
  
  context "For an Escaped Feed" do
    before(:each) do
      # I don't really like doing it this way because these unit test should only rely on AtomEntry,
      # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
      @entry = Feedzirra::Parser::Atom.parse(sample_atom_feed).entries.first
    end
  
    it "should parse the title" do
      @entry.title.should == "AWS Job: Architect & Designer Position in Turkey"
    end
  
    it "should parse the url" do
      @entry.url.should == "http://aws.typepad.com/aws/2009/01/aws-job-architect-designer-position-in-turkey.html"
    end
  
    it "should parse the url even when" do
      Feedzirra::Parser::Atom.parse(load_sample("atom_with_link_tag_for_url_unmarked.xml")).entries.first.url.should == "http://www.innoq.com/blog/phaus/2009/07/ja.html"
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
  
    it "should parse the updated date" do
      @entry.updated.to_s.should == "Fri Jan 16 18:21:00 UTC 2009"
    end
  
    it "should parse the id" do
      @entry.id.should == "tag:typepad.com,2003:post-61484736"
    end
  end
  
  
  context "For an Unescaped Feed" do
    before(:each) do
      # I don't really like doing it this way because these unit test should only rely on AtomEntry,
      # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
      @entry = Feedzirra::Parser::Atom.parse(sample_atom_unescaped_feed).entries.first
    end
  
    it "should parse the title" do
      @entry.title.should == "GoughNuts Stick and Treats by Kona's Chips"
    end
  
    it "should parse the url" do
      @entry.url.should == "http://www.petsecretshopper.com/2011/04/goughnuts-stick-and-treats-by-konas-chips.html"
    end
  
    it "should parse the url even when" do
      Feedzirra::Parser::Atom.parse(load_sample("atom_with_link_tag_for_url_unmarked.xml")).entries.first.url.should == "http://www.innoq.com/blog/phaus/2009/07/ja.html"
    end
  
    it "should parse the author" do
      @entry.author.should == "Jocelyn Tobin"
    end
  
    it "should parse the content" do
      @entry.content.should == sample_atom_unescaped_entry_content
    end
  
    it "should provide a summary" do
      @entry.summary.should == "Pet Product Review: GoughNuts Stick and Treats by Kona's Chips I have always been one to support American made products, but before reading the story of Kona I had no idea just how dangerous products that are foreign made can be. There have been several recalls on China produced dog..."
    end
  
    it "should parse the published date" do
      @entry.published.to_s.should == "Fri Apr 29 19:39:48 UTC 2011"
    end

    it "should parse the categories" do
      @entry.categories.should == ["Books", "Dog Toys", "Dogs", "Pet Supplies", "Pets", "Weblogs"]
    end
  
    it "should parse the updated date" do
      @entry.updated.to_s.should == "Fri Apr 29 19:40:28 UTC 2011"
    end
  
    it "should parse the id" do
      @entry.id.should == "tag:typepad.com,2003:post-6a010535222d03970c01543200a81f970c"
    end
  end
  
  
end