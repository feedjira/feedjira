# frozen_string_literal: true

require "spec_helper"

RSpec.describe Feedjira::AtomEntryUtilities do
  def klass
    Class.new do
      include SAXMachine
      include Feedjira::AtomEntryUtilities
    end
  end

  describe "#title" do
    it "returns the title when set" do
      entry = klass.new
      entry.title = "My Title"

      expect(entry.title).to eq "My Title"
    end

    it "returns a sanitized version of the raw title when present" do
      entry = klass.new
      entry.raw_title = "My <b>Raw</b> \tTitle"

      expect(entry.title).to eq "My Raw Title"
    end

    it "returns nil when no raw title is present" do
      entry = klass.new

      expect(entry.title).to be_nil
    end
  end

  describe "#url" do
    it "returns the url when set" do
      entry = klass.new
      entry.url = "http://exampoo.com/feed"

      expect(entry.url).to eq "http://exampoo.com/feed"
    end

    it "returns the first link when not set" do
      entry = klass.new
      entry.links = ["http://exampoo.com/feed"]

      expect(entry.url).to eq "http://exampoo.com/feed"
    end
  end
end
