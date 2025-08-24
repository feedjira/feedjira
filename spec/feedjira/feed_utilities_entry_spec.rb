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

  describe "updated= method" do
    it "sets updated when no existing updated value and parsed date is valid" do
      instance = @klass.new
      instance.updated = "2023-01-01T10:00:00Z"
      expect(instance["updated"]).to eq Time.parse("2023-01-01T10:00:00Z").utc
    end

    it "updates to newer date when existing updated value is older" do
      instance = @klass.new
      instance.updated = "2023-01-01T10:00:00Z"
      instance.updated = "2023-01-02T10:00:00Z"
      expect(instance["updated"]).to eq Time.parse("2023-01-02T10:00:00Z").utc
    end

    it "keeps existing updated value when new date is older" do
      instance = @klass.new
      instance.updated = "2023-01-02T10:00:00Z"
      instance.updated = "2023-01-01T10:00:00Z"
      expect(instance["updated"]).to eq Time.parse("2023-01-02T10:00:00Z").utc
    end

    it "does not set updated when date parsing fails" do
      instance = @klass.new
      instance.updated = "invalid-date"
      expect(instance["updated"]).to be_nil
    end

    it "does not change existing updated when new date is invalid" do
      instance = @klass.new
      instance.updated = "2023-01-01T10:00:00Z"
      original_updated = instance["updated"]
      instance.updated = "invalid-date"
      expect(instance["updated"]).to eq original_updated
    end
  end

  describe "published= method" do
    it "sets published when no existing published value and parsed date is valid" do
      instance = @klass.new
      instance.published = "2023-01-01T10:00:00Z"
      expect(instance["published"]).to eq Time.parse("2023-01-01T10:00:00Z").utc
    end

    it "updates to older date when existing published value is newer" do
      instance = @klass.new
      instance.published = "2023-01-02T10:00:00Z"
      instance.published = "2023-01-01T10:00:00Z"
      expect(instance["published"]).to eq Time.parse("2023-01-01T10:00:00Z").utc
    end

    it "keeps existing published value when new date is newer" do
      instance = @klass.new
      instance.published = "2023-01-01T10:00:00Z"
      instance.published = "2023-01-02T10:00:00Z"
      expect(instance["published"]).to eq Time.parse("2023-01-01T10:00:00Z").utc
    end

    it "does not set published when date parsing fails" do
      instance = @klass.new
      instance.published = "invalid-date"
      expect(instance["published"]).to be_nil
    end

    it "does not change existing published when new date is invalid" do
      instance = @klass.new
      instance.published = "2023-01-01T10:00:00Z"
      original_published = instance["published"]
      instance.published = "invalid-date"
      expect(instance["published"]).to eq original_published
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
      scrubbed_title = Loofah.scrub_fragment(new_title, :prune).to_s
      expect(Loofah.scrub_fragment(@entry.title, :prune).to_s).to eq scrubbed_title
    end

    it "sanitizes content in place" do
      new_content = "<script>#{@entry.content}"
      @entry.content = new_content.dup

      scrubbed_content = Loofah.scrub_fragment(new_content, :prune).to_s

      @entry.sanitize!
      expect(@entry.content).to eq scrubbed_content
    end

    it "sanitizes things in place" do
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
