# frozen_string_literal: true

require "spec_helper"

describe Feedjira::Parser::ITunesRSSCategory do
  describe "#each_subcategory" do
    it "returns an enumerator when no block is given" do
      category = described_class.new
      category.text = "Technology"

      result = category.each_subcategory
      expect(result).to be_an(Enumerator)
    end

    it "yields category text and subcategories when block is given" do
      parent_category = described_class.new
      parent_category.text = "Technology"

      subcategory = described_class.new
      subcategory.text = "Gadgets"

      parent_category.itunes_categories = [subcategory]

      yielded_categories = []
      parent_category.each_subcategory { |cat| yielded_categories << cat }

      expect(yielded_categories).to eq %w[Technology Gadgets]
    end
  end

  describe "#each_path" do
    it "returns an enumerator when no block is given" do
      category = described_class.new
      category.text = "Technology"

      result = category.each_path
      expect(result).to be_an(Enumerator)
    end
  end
end
