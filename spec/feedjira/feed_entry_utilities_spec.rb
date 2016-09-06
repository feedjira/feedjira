require 'spec_helper'

describe Feedjira::FeedUtilities do
  before(:each) do
    @klass = Class.new do
      include Feedjira::FeedEntryUtilities
    end
  end

  describe "sanitizing" do
    before(:each) do
      @feed = Feedjira::Feed.parse(sample_atom_feed)
      @entry = @feed.entries.first
    end

    it "doesn't fail when no elements are defined on includer" do
      expect { @klass.new.sanitize! }.to_not raise_error
    end

    it "should provide a sanitized title" do
      new_title = "<script>this is not safe</script>" + @entry.title
      @entry.title = new_title
      expect(@entry.title.sanitize).to eq Loofah.scrub_fragment(new_title, :prune).to_s
    end

    it "should sanitize content in place" do
      new_content = "<script>" + @entry.content
      @entry.content = new_content.dup
      expect(@entry.content.sanitize!).to eq Loofah.scrub_fragment(new_content, :prune).to_s
      expect(@entry.content).to eq Loofah.scrub_fragment(new_content, :prune).to_s
    end

    it "should sanitize things in place" do
      @entry.title   += "<script>"
      @entry.author  += "<script>"
      @entry.content += "<script>"

      cleaned_title   = Loofah.scrub_fragment(@entry.title, :prune).to_s
      cleaned_author  = Loofah.scrub_fragment(@entry.author, :prune).to_s
      cleaned_content = Loofah.scrub_fragment(@entry.content, :prune).to_s

      @entry.sanitize!
      expect(@entry.title).to   eq cleaned_title
      expect(@entry.author).to  eq cleaned_author
      expect(@entry.content).to eq cleaned_content
    end
  end
end
