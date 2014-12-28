require File.dirname(__FILE__) + '/../spec_helper'

class Hell < StandardError; end

class FailParser
  def self.parse(_, &on_failure)
    on_failure.call 'this parser always fails.'
  end
end

describe Feedjira::Feed do
  describe '.fetch_and_parse' do
    it 'raises an error when the fetch fails' do
      url = 'http://www.example.com/feed.xml'
      expect {
        Feedjira::Feed.fetch_and_parse url
      }.to raise_error Feedjira::FetchFailure
    end

    it 'raises an error when no parser can be found' do
      url = 'http://feedjira.com'
      expect {
        Feedjira::Feed.fetch_and_parse url
      }.to raise_error Feedjira::NoParserAvailable
    end

    it 'fetches and parses the feed' do
      url = 'http://feedjira.com/blog/feed.xml'
      feed = Feedjira::Feed.fetch_and_parse url

      expect(feed.class).to eq Feedjira::Parser::Atom
      expect(feed.entries.count).to eq 3
      expect(feed.feed_url).to eq url
      expect(feed.etag).to eq 'a22ad-3190-5037e71966e80'
      expect(feed.last_modified).to eq 'Sat, 20 Sep 2014 12:34:50 GMT'
    end
  end

  describe "#add_common_feed_element" do
    before(:all) do
      Feedjira::Feed.add_common_feed_element("generator")
    end

    it "should parse the added element out of Atom feeds" do
      expect(Feedjira::Feed.parse(sample_wfw_feed).generator).to eq "TypePad"
    end

    it "should parse the added element out of Atom Feedburner feeds" do
      expect(Feedjira::Parser::Atom.new).to respond_to(:generator)
    end

    it "should parse the added element out of RSS feeds" do
      expect(Feedjira::Parser::RSS.new).to respond_to(:generator)
    end
  end

  describe "#add_common_feed_entry_element" do
    before(:all) do
      Feedjira::Feed.add_common_feed_entry_element("wfw:commentRss", :as => :comment_rss)
    end

    it "should parse the added element out of Atom feeds entries" do
      expect(Feedjira::Feed.parse(sample_wfw_feed).entries.first.comment_rss).to eq "this is the new val"
    end

    it "should parse the added element out of Atom Feedburner feeds entries" do
      expect(Feedjira::Parser::AtomEntry.new).to respond_to(:comment_rss)
    end

    it "should parse the added element out of RSS feeds entries" do
      expect(Feedjira::Parser::RSSEntry.new).to respond_to(:comment_rss)
    end
  end

  describe '#parse_with' do
    let(:xml) { '<xml></xml>' }

    it 'invokes the parser and passes the xml' do
      parser = double 'Parser', parse: nil
      expect(parser).to receive(:parse).with xml
      Feedjira::Feed.parse_with parser, xml
    end

    context 'with a callback block' do
      it 'passes the callback to the parser' do
        callback = ->(*) { raise Hell }

        expect do
          Feedjira::Feed.parse_with FailParser, xml, &callback
        end.to raise_error Hell
      end
    end
  end

  describe "#parse" do # many of these tests are redundant with the specific feed type tests, but I put them here for completeness
    context "when there's an available parser" do
      it "should parse an rdf feed" do
        feed = Feedjira::Feed.parse(sample_rdf_feed)
        expect(feed.title).to eq "HREF Considered Harmful"
        expect(feed.entries.first.published).to eq Time.parse_safely("Tue Sep 02 19:50:07 UTC 2008")
        expect(feed.entries.size).to eq 10
      end

      it "should parse an rss feed" do
        feed = Feedjira::Feed.parse(sample_rss_feed)
        expect(feed.title).to eq "Tender Lovemaking"
        expect(feed.entries.first.published).to eq Time.parse_safely("Thu Dec 04 17:17:49 UTC 2008")
        expect(feed.entries.size).to eq 10
      end

      it "should parse an atom feed" do
        feed = Feedjira::Feed.parse(sample_atom_feed)
        expect(feed.title).to eq "Amazon Web Services Blog"
        expect(feed.entries.first.published).to eq Time.parse_safely("Fri Jan 16 18:21:00 UTC 2009")
        expect(feed.entries.size).to eq 10
      end

      it "should parse an feedburner atom feed" do
        feed = Feedjira::Feed.parse(sample_feedburner_atom_feed)
        expect(feed.title).to eq "Paul Dix Explains Nothing"
        expect(feed.entries.first.published).to eq Time.parse_safely("Thu Jan 22 15:50:22 UTC 2009")
        expect(feed.entries.size).to eq 5
      end

      it "should parse an itunes feed" do
        feed = Feedjira::Feed.parse(sample_itunes_feed)
        expect(feed.title).to eq "All About Everything"
        expect(feed.entries.first.published).to eq Time.parse_safely("Wed, 15 Jun 2005 19:00:00 GMT")
        expect(feed.entries.size).to eq 3
      end
    end

    context "when there's no available parser" do
      it "raises Feedjira::NoParserAvailable" do
        expect {
          Feedjira::Feed.parse("I'm an invalid feed")
        }.to raise_error(Feedjira::NoParserAvailable)
      end
    end

    it "should parse an feedburner rss feed" do
      feed = Feedjira::Feed.parse(sample_rss_feed_burner_feed)
      expect(feed.title).to eq "TechCrunch"
      expect(feed.entries.first.published).to eq Time.parse_safely("Wed Nov 02 17:25:27 UTC 2011")
      expect(feed.entries.size).to eq 20
    end
  end

  describe "#determine_feed_parser_for_xml" do
    it 'should return the Feedjira::Parser::GoogleDocsAtom calss for a Google Docs atom feed' do
      expect(Feedjira::Feed.determine_feed_parser_for_xml(sample_google_docs_list_feed)).to eq Feedjira::Parser::GoogleDocsAtom
    end

    it "should return the expect(Feedjira::Parser::Atom class for an atom feed" do
      expect(Feedjira::Feed.determine_feed_parser_for_xml(sample_atom_feed)).to eq Feedjira::Parser::Atom
    end

    it "should return the expect(Feedjira::Parser::AtomFeedBurner class for an atom feedburner feed" do
      expect(Feedjira::Feed.determine_feed_parser_for_xml(sample_feedburner_atom_feed)).to eq Feedjira::Parser::AtomFeedBurner
    end

    it "should return the expect(Feedjira::Parser::RSS class for an rdf/rss 1.0 feed" do
      expect(Feedjira::Feed.determine_feed_parser_for_xml(sample_rdf_feed)).to eq Feedjira::Parser::RSS
    end

    it "should return the expect(Feedjira::Parser::RSSFeedBurner class for an rss feedburner feed" do
      expect(Feedjira::Feed.determine_feed_parser_for_xml(sample_rss_feed_burner_feed)).to eq Feedjira::Parser::RSSFeedBurner
    end

    it "should return the expect(Feedjira::Parser::RSS object for an rss 2.0 feed" do
      expect(Feedjira::Feed.determine_feed_parser_for_xml(sample_rss_feed)).to eq Feedjira::Parser::RSS
    end

    it "should return a expect(Feedjira::Parser::RSS object for an itunes feed" do
      expect(Feedjira::Feed.determine_feed_parser_for_xml(sample_itunes_feed)).to eq Feedjira::Parser::ITunesRSS
    end

  end

  describe "when adding feed types" do
    it "should prioritize added types over the built in ones" do
      feed_text = "Atom asdf"
      allow(Feedjira::Parser::Atom).to receive(:able_to_parse?).and_return(true)
      new_feed_type = Class.new do
        def self.able_to_parse?(val)
          true
        end
      end

      expect(new_feed_type).to be_able_to_parse(feed_text)
      Feedjira::Feed.add_feed_class(new_feed_type)
      expect(Feedjira::Feed.determine_feed_parser_for_xml(feed_text)).to eq new_feed_type

      # this is a hack so that this doesn't break the rest of the tests
      Feedjira::Feed.feed_classes.reject! {|o| o == new_feed_type }
    end
  end
end
