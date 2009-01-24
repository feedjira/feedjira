require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::RSS do
  describe "#will_parse?" do
    it "should return true for an RSS feed" do
      Feedzirra::RSS.will_parse?(sample_rss_feed).should be_true
    end
    
    it "should return false for an rdf feed" do
      Feedzirra::RSS.will_parse?(sample_rdf_feed).should be_false
    end
    
    it "should return fase for an atom feed" do
      Feedzirra::RSS.will_parse?(sample_atom_feed).should be_false
    end
  end
end