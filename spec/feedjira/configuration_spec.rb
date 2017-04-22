require "spec_helper"

describe Feedjira::Configuration do
  describe ".configure" do
    it "sets strip_whitespace config" do
      Feedjira.configure { |config| config.strip_whitespace = true }
      expect(Feedjira.strip_whitespace).to be true
    end
  end
end
