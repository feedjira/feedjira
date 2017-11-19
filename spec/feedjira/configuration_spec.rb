require "spec_helper"

describe Feedjira::Configuration do
  describe ".configure" do
    it "sets strip_whitespace config" do
      Feedjira.configure { |config| config.strip_whitespace = true }
      expect(Feedjira.strip_whitespace).to be true
    end

    it "allows parsers to be modified" do
      original_parsers = Feedjira.parsers

      CustomParser = Class.new

      Feedjira.configure { |config| config.parsers.unshift(CustomParser) }
      expect(Feedjira.parsers.first).to eq(CustomParser)
      Feedjira.configure { |config| config.parsers = original_parsers }
    end
  end
end
