require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::AtomFeedBurner do
  describe "#will_parse?" do
    it "should return true for a feedburner atom feed" do
      Feedzirra::AtomFeedBurner.will_parse?(sample_feedburner_atom_feed).should be_true
    end
    
    it "should return false for an rdf feed" do
      Feedzirra::AtomFeedBurner.will_parse?(sample_rdf_feed).should be_false
    end
    
    it "should return false for a regular atom feed" do
      Feedzirra::AtomFeedBurner.will_parse?(sample_atom_feed).should be_false
    end
  end
end