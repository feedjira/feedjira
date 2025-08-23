# frozen_string_literal: true

require "spec_helper"

RSpec.describe Feedjira::Utils do
  describe ".parse_time_safely" do
    it "returns the datetime in utc when given a Time" do
      time = Time.now

      expect(described_class.parse_time_safely(time)).to eq(time.utc)
    end

    it "returns the datetime in utc when given a Date" do
      date = Date.today

      expect(described_class.parse_time_safely(date)).to eq(date.to_time.utc)
    end

    it "returns the datetime in utc when given a String" do
      timestamp = "2016-01-01 00:00:00"

      expect(described_class.parse_time_safely(timestamp)).to eq(Time.parse(timestamp).utc)
    end

    it "returns nil when given an empty String" do
      timestamp = ""

      expect(described_class.parse_time_safely(timestamp)).to be_nil
    end

    it "returns the the datetime in utc given a 14-digit time" do
      time = Time.now.utc
      timestamp = time.strftime("%Y%m%d%H%M%S")

      expect(described_class.parse_time_safely(timestamp)).to eq(time.floor)
    end

    context "when given an invalid time string" do
      it "returns nil" do
        timestamp = "2016-51-51 00:00:00"

        expect(described_class.parse_time_safely(timestamp)).to be_nil
      end

      it "logs an error" do
        timestamp = "2016-51-51 00:00:00"

        expect(Feedjira.logger)
          .to receive(:debug).with("Failed to parse time #{timestamp}")
        expect(Feedjira.logger)
          .to receive(:debug).with(an_instance_of(ArgumentError))

        described_class.parse_time_safely(timestamp)
      end
    end
  end

  describe ".date_to_gm_time" do
    it "converts a Date to GMT Time" do
      date = Date.new(2020, 1, 1)
      expected_time = Time.gm(2020, 1, 1, 0, 0, 0, 0)

      result = described_class.date_to_gm_time(date)

      expect(result).to eq(expected_time)
    end

    it "handles dates with fractional seconds" do
      # Create a DateTime with fractional seconds
      datetime = DateTime.new(2020, 1, 1, 12, 30, 45.123456)
      expected_time = Time.gm(2020, 1, 1, 12, 30, 45, 123456)

      result = described_class.date_to_gm_time(datetime)

      expect(result).to eq(expected_time)
    end
  end

  describe ".sanitize_string" do
    it "removes script tags" do
      string = "Hello <script>alert('xss')</script> world"
      expected = "Hello  world"

      expect(described_class.sanitize_string(string)).to eq(expected)
    end

    it "keeps safe HTML tags" do
      string = "Hello <p>world</p>"
      expected = "Hello <p>world</p>"

      expect(described_class.sanitize_string(string)).to eq(expected)
    end

    it "handles empty strings" do
      expect(described_class.sanitize_string("")).to eq("")
    end
  end
end