require File.dirname(__FILE__) + '/../spec_helper'

describe Feedzirra::Feed do
  describe "#feed_parser_for_xml" do
    it "should return a Feedzirra::Atom object for an atom feed"
    it "should return a Feedzirra::AtomFeedBurner object for an atom feedburner feed"
    it "should return a Feedzirra::RDF object for an rdf/rss 1.0 feed"
  end
end