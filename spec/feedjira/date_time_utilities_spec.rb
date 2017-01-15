require 'spec_helper'

describe Feedjira::FeedUtilities do
  before(:each) do
    @klass = Class.new do
      include Feedjira::DateTimeUtilities
    end
  end

  describe 'handling dates' do
    it 'should parse an ISO 8601 formatted datetime into Time' do
      time = @klass.new.parse_datetime('2008-02-20T8:05:00-010:00')
      expect(time.class).to eq Time
      expect(time).to eq Time.parse_safely('Wed Feb 20 18:05:00 UTC 2008')
    end

    it 'should parse a ISO 8601 with milliseconds into Time' do
      time = @klass.new.parse_datetime('2013-09-17T08:20:13.931-04:00')
      expect(time.class).to eq Time
      expect(time).to eq Time.parse_safely('Tue Sep 17 12:20:13 UTC 2013')
    end

    it 'should parse a US Format into Time' do
      time = @klass.new.parse_datetime('8/23/2016 12:29:58 PM')
      expect(time.class).to eq Time
      expect(time).to eq Time.parse_safely('Wed Aug 23 12:29:58 UTC 2016')
    end

    it 'should parse a Spanish Format into Time' do
      time = @klass.new.parse_datetime('Wed, 31 Ago 2016 11:08:22 GMT')
      expect(time.class).to eq Time
      expect(time).to eq Time.parse_safely('Wed Aug 31 11:08:22 UTC 2016')
    end

    it 'should parse Format with japanese symbols into Time' do
      time = @klass.new.parse_datetime('水, 31 8 2016 07:37:00 PDT')
      expect(time.class).to eq Time
      expect(time).to eq Time.parse_safely('Wed Aug 31 14:37:00 UTC 2016')
    end

    it 'should parse epoch into Time' do
      time = @klass.new.parse_datetime('1472654220')
      expect(time.class).to eq Time
      expect(time).to eq Time.parse_safely('Wed Aug 31 14:37:00 UTC 2016')
    end
  end
end
