require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::RDF do
  describe "#will_parse?" do
    it "should return true for an rdf feed" do
      Feedzirra::RDF.will_parse?(sample_rdf_feed).should be_true
    end
    
    it "should return false for an atom feed" do
      Feedzirra::RDF.will_parse?(sample_atom_feed).should be_false
    end
  end
end