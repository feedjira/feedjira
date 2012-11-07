require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::ITunesRSS do
  describe "#will_parse?" do
    it "should return true for an itunes RSS feed" do
      Feedzirra::Parser::ITunesRSS.should be_able_to_parse(sample_itunes_feed)
    end

    it "should return true for an itunes RSS feed with spaces between attribute names, equals sign, and values" do
      Feedzirra::Parser::ITunesRSS.should be_able_to_parse(sample_itunes_feed_with_spaces)
    end

    it "should return fase for an atom feed" do
      Feedzirra::Parser::ITunesRSS.should_not be_able_to_parse(sample_atom_feed)
    end
    
    it "should return false for an rss feedburner feed" do
      Feedzirra::Parser::ITunesRSS.should_not be_able_to_parse(sample_rss_feed_burner_feed)
    end
  end

  describe "parsing" do
    before(:each) do
      @feed = Feedzirra::Parser::ITunesRSS.parse(sample_itunes_feed)
    end
    
    it "should parse the subtitle" do
      @feed.itunes_subtitle.should == "A show about everything"
    end
    
    it "should parse the author" do
      @feed.itunes_author.should == "John Doe"
    end
    
    it "should parse an owner" do
      @feed.itunes_owners.size.should == 1
    end
    
    it "should parse an image" do
      @feed.itunes_image.should == "http://example.com/podcasts/everything/AllAboutEverything.jpg"
    end
    
    it "should parse categories" do
      @feed.itunes_categories.size == 3
      @feed.itunes_categories[0] == "Technology"
      @feed.itunes_categories[1] == "Gadgets"
      @feed.itunes_categories[2] == "TV &amp; Film"
    end

    it "should parse the summary" do
      @feed.itunes_summary.should == "All About Everything is a show about everything. Each week we dive into any subject known to man and talk about it as much as we can. Look for our Podcast in the iTunes Music Store"
    end
    
    it "should parse entries" do
      @feed.entries.size.should == 3
    end
  end
end