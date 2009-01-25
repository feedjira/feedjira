require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::FeedUtilities do
  before(:each) do
    @klass = Class.new do
      include Feedzirra::FeedUtilities
    end
  end
  
  describe "handling dates" do
    it "should parse an ISO 8601 formatted datetime into Time" do
      time = @klass.new.parse_datetime("2008-02-20T8:05:00-010:00")
      time.class.should == Time
      time.to_s.should == "Wed Feb 20 18:05:00 UTC 2008"
    end
  end
end