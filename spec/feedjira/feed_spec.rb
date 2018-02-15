require 'spec_helper'

# rubocop:disable Style/BlockDelimiters

class Hell < StandardError; end

class FailParser
  def self.parse(_, &on_failure)
    on_failure.call 'this parser always fails.'
  end
end

describe Feedjira::Feed do
  describe '.fetch_and_parse' do
    it 'raises an error when the fetch fails' do
      VCR.use_cassette('fetch_failure') do
        url = 'http://www.example.com/feed.xml'
        expect {
          Feedjira::Feed.fetch_and_parse url
        }.to raise_error Feedjira::FetchFailure
      end
    end

    it 'raises an error when no parser can be found' do
      VCR.use_cassette('parse_error') do
        url = 'http://feedjira.com'
        expect {
          Feedjira::Feed.fetch_and_parse url
        }.to raise_error Feedjira::NoParserAvailable
      end
    end

    it 'fetches and parses the feed' do
      VCR.use_cassette('success') do
        url = 'http://feedjira.com/blog/feed.xml'
        expected_time = DateTime.parse('Fri, 07 Oct 2016 14:37:00 GMT').to_time
        feed = Feedjira::Feed.fetch_and_parse url

        expect(feed.class).to eq Feedjira::Parser::Atom
        expect(feed.entries.count).to eq 4
        expect(feed.feed_url).to eq url
        expect(feed.etag).to eq('393e-53e4757c9db00-gzip')
        expect(feed.last_modified).to eq(expected_time)
      end
    end
  end

  describe '#add_common_feed_element' do
    before(:all) do
      Feedjira::Feed.add_common_feed_element('generator')
    end

    it 'should parse the added element out of Atom feeds' do
      expect(Feedjira::Feed.parse(sample_wfw_feed).generator).to eq 'TypePad'
    end

    it 'should parse the added element out of Atom Feedburner feeds' do
      expect(Feedjira::Parser::Atom.new).to respond_to(:generator)
    end

    it 'should parse the added element out of RSS feeds' do
      expect(Feedjira::Parser::RSS.new).to respond_to(:generator)
    end
  end

  describe '#add_common_feed_entry_element' do
    before(:all) do
      tag = 'wfw:commentRss'
      Feedjira::Feed.add_common_feed_entry_element tag, as: :comment_rss
    end

    it 'should parse the added element out of Atom feeds entries' do
      entry = Feedjira::Feed.parse(sample_wfw_feed).entries.first
      expect(entry.comment_rss).to eq 'this is the new val'
    end

    it 'should parse the added element out of Atom Feedburner feeds entries' do
      expect(Feedjira::Parser::AtomEntry.new).to respond_to(:comment_rss)
    end

    it 'should parse the added element out of RSS feeds entries' do
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

  describe '#parse' do
    context "when there's an available parser" do
      it 'should parse an rdf feed' do
        feed = Feedjira::Feed.parse(sample_rdf_feed)
        expect(feed.title).to eq 'HREF Considered Harmful'
        published = Time.parse_safely('Tue Sep 02 19:50:07 UTC 2008')
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 10
      end

      it 'should parse an rss feed' do
        feed = Feedjira::Feed.parse(sample_rss_feed)
        expect(feed.title).to eq 'Tender Lovemaking'
        published = Time.parse_safely 'Thu Dec 04 17:17:49 UTC 2008'
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 10
      end

      it 'should parse an atom feed' do
        feed = Feedjira::Feed.parse(sample_atom_feed)
        expect(feed.title).to eq 'Amazon Web Services Blog'
        published = Time.parse_safely 'Fri Jan 16 18:21:00 UTC 2009'
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 10
      end

      it 'should parse an feedburner atom feed' do
        feed = Feedjira::Feed.parse(sample_feedburner_atom_feed)
        expect(feed.title).to eq 'Paul Dix Explains Nothing'
        published = Time.parse_safely 'Thu Jan 22 15:50:22 UTC 2009'
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 5
      end

      it 'should parse an itunes feed' do
        feed = Feedjira::Feed.parse(sample_itunes_feed)
        expect(feed.title).to eq 'All About Everything'
        published = Time.parse_safely 'Wed, 15 Jun 2005 19:00:00 GMT'
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 3
      end

      it 'does not fail if multiple published dates exist and some are unparseable' do
        expect(Feedjira.logger).to receive(:warn).once

        feed = Feedjira::Feed.parse(sample_invalid_date_format_feed)
        expect(feed.title).to eq 'Invalid date format feed'
        published = Time.parse_safely 'Mon, 16 Oct 2017 15:10:00 GMT'
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 2
      end
    end

    context "when there's no available parser" do
      it 'raises Feedjira::NoParserAvailable' do
        expect {
          Feedjira::Feed.parse("I'm an invalid feed")
        }.to raise_error(Feedjira::NoParserAvailable)
      end
    end

    it 'should parse an feedburner rss feed' do
      feed = Feedjira::Feed.parse(sample_rss_feed_burner_feed)
      expect(feed.title).to eq 'TechCrunch'
      published = Time.parse_safely 'Wed Nov 02 17:25:27 UTC 2011'
      expect(feed.entries.first.published).to eq published
      expect(feed.entries.size).to eq 20
    end
  end

  describe '#determine_feed_parser_for_xml' do
    it 'with Google Docs atom feed it returns the GoogleDocsAtom parser' do
      xml = sample_google_docs_list_feed
      actual_parser = Feedjira::Feed.determine_feed_parser_for_xml xml
      expect(actual_parser).to eq Feedjira::Parser::GoogleDocsAtom
    end

    it 'with an atom feed it returns the Atom parser' do
      xml = sample_atom_feed
      actual_parser = Feedjira::Feed.determine_feed_parser_for_xml xml
      expect(actual_parser).to eq Feedjira::Parser::Atom
    end

    it 'with an atom feedburner feed it returns the AtomFeedBurner parser' do
      xml = sample_feedburner_atom_feed
      actual_parser = Feedjira::Feed.determine_feed_parser_for_xml xml
      expect(actual_parser).to eq Feedjira::Parser::AtomFeedBurner
    end

    it 'with an rdf feed it returns the RSS parser' do
      xml = sample_rdf_feed
      actual_parser = Feedjira::Feed.determine_feed_parser_for_xml xml
      expect(actual_parser).to eq Feedjira::Parser::RSS
    end

    it 'with an rss feedburner feed it returns the RSSFeedBurner parser' do
      xml = sample_rss_feed_burner_feed
      actual_parser = Feedjira::Feed.determine_feed_parser_for_xml xml
      expect(actual_parser).to eq Feedjira::Parser::RSSFeedBurner
    end

    it 'with an rss 2.0 feed it returns the RSS parser' do
      xml = sample_rss_feed
      actual_parser = Feedjira::Feed.determine_feed_parser_for_xml xml
      expect(actual_parser).to eq Feedjira::Parser::RSS
    end

    it 'with an itunes feed it returns the RSS parser' do
      xml = sample_itunes_feed
      actual_parser = Feedjira::Feed.determine_feed_parser_for_xml xml
      expect(actual_parser).to eq Feedjira::Parser::ITunesRSS
    end
  end

  describe 'when adding feed types' do
    it 'should prioritize added types over the built in ones' do
      xml = 'Atom asdf'
      allow(Feedjira::Parser::Atom).to receive(:able_to_parse?).and_return(true)
      new_parser = Class.new do
        def self.able_to_parse?(_)
          true
        end
      end

      expect(new_parser).to be_able_to_parse(xml)

      Feedjira::Feed.add_feed_class(new_parser)

      parser = Feedjira::Feed.determine_feed_parser_for_xml xml
      expect(parser).to eq new_parser

      Feedjira::Feed.reset_parsers!
    end
  end

  describe 'when parsers are configured' do
    it 'does not use default parsers' do
      xml = 'Atom asdf'
      new_parser = Class.new do
        def self.able_to_parse?(_)
          true
        end
      end

      Feedjira.configure { |config| config.parsers = [new_parser] }

      parser = Feedjira::Feed.determine_feed_parser_for_xml(xml)
      expect(parser).to eq(new_parser)

      Feedjira.reset_configuration!
      Feedjira::Feed.reset_parsers!
    end
  end
end

# rubocop:enable Style/BlockDelimiters
