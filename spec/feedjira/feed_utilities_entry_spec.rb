# frozen_string_literal: true

require "spec_helper"

describe Feedjira::FeedUtilities do
  before do
    @klass = Class.new do
      include Feedjira::FeedEntryUtilities
    end
  end

  describe "handling dates" do
    it "parses an ISO 8601 formatted datetime into Time" do
      time = @klass.new.parse_datetime("2008-02-20T8:05:00-010:00")
      expect(time.class).to eq Time
      expect(time).to eq Feedjira::Util::ParseTime.call("Wed Feb 20 18:05:00 UTC 2008")
    end

    it "parses a ISO 8601 with milliseconds into Time" do
      time = @klass.new.parse_datetime("2013-09-17T08:20:13.931-04:00")
      expect(time.class).to eq Time
      expect(time).to eq Time.strptime("Tue Sep 17 12:20:13.931 UTC 2013", "%a %b %d %H:%M:%S.%N %Z %Y")
    end
  end

  describe "sanitizing" do
    before do
      @feed = Feedjira.parse(sample_atom_feed)
      @entry = @feed.entries.first
    end

    it "doesn't fail when no elements are defined on includer" do
      expect { @klass.new.sanitize! }.not_to raise_error
    end

    it "provides a sanitized title" do
      new_title = "<script>this is not safe</script>#{@entry.title}"
      @entry.title = new_title
      scrubbed_title = Feedjira::Util::Sanitizer.sanitize(new_title)
      expect(Feedjira::Util::Sanitizer.sanitize(@entry.title)).to eq scrubbed_title
    end

    it "sanitizes content in place" do
      new_content = "<script>#{@entry.content}"
      @entry.content = new_content.dup

      scrubbed_content = Feedjira::Util::Sanitizer.sanitize(new_content)

      expect(Feedjira::Util::Sanitizer.sanitize!(@entry.content)).to eq scrubbed_content
      expect(@entry.content).to eq scrubbed_content
    end

    it "sanitizes things in place" do
      @entry.title   += "<script>"
      @entry.author  += "<script>"
      @entry.content += "<script>"

      cleaned_title   = Feedjira::Util::Sanitizer.sanitize(@entry.title)
      cleaned_author  = Feedjira::Util::Sanitizer.sanitize(@entry.author)
      cleaned_content = Feedjira::Util::Sanitizer.sanitize(@entry.content)

      @entry.sanitize!
      expect(@entry.title).to   eq cleaned_title
      expect(@entry.author).to  eq cleaned_author
      expect(@entry.content).to eq cleaned_content
    end
  end
end
