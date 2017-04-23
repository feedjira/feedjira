require "spec_helper"

RSpec.describe Feedjira do
  describe ".parse" do
    context "when there's an available parser" do
      it "should parse an rdf feed" do
        feed = Feedjira.parse(sample_rdf_feed)
        expect(feed.title).to eq "HREF Considered Harmful"
        published = Time.parse_safely("Tue Sep 02 19:50:07 UTC 2008")
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 10
      end

      it "should parse an rss feed" do
        feed = Feedjira.parse(sample_rss_feed)
        expect(feed.title).to eq "Tender Lovemaking"
        published = Time.parse_safely "Thu Dec 04 17:17:49 UTC 2008"
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 10
      end

      it "should parse an atom feed" do
        feed = Feedjira.parse(sample_atom_feed)
        expect(feed.title).to eq "Amazon Web Services Blog"
        published = Time.parse_safely "Fri Jan 16 18:21:00 UTC 2009"
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 10
      end

      it "should parse an feedburner atom feed" do
        feed = Feedjira.parse(sample_feedburner_atom_feed)
        expect(feed.title).to eq "Paul Dix Explains Nothing"
        published = Time.parse_safely "Thu Jan 22 15:50:22 UTC 2009"
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 5
      end

      it "should parse an itunes feed" do
        feed = Feedjira.parse(sample_itunes_feed)
        expect(feed.title).to eq "All About Everything"
        published = Time.parse_safely "Wed, 15 Jun 2005 19:00:00 GMT"
        expect(feed.entries.first.published).to eq published
        expect(feed.entries.size).to eq 3
      end
    end

    context "when there's no available parser" do
      it "raises Feedjira::NoParserAvailable" do
        expect do
          Feedjira.parse("I'm an invalid feed")
        end.to raise_error(Feedjira::NoParserAvailable)
      end
    end

    it "should parse an feedburner rss feed" do
      feed = Feedjira.parse(sample_rss_feed_burner_feed)
      expect(feed.title).to eq "TechCrunch"
      published = Time.parse_safely "Wed Nov 02 17:25:27 UTC 2011"
      expect(feed.entries.first.published).to eq published
      expect(feed.entries.size).to eq 20
    end
  end

  describe ".parser_for_xml" do
    it "with Google Docs atom feed it returns the GoogleDocsAtom parser" do
      xml = sample_google_docs_list_feed
      actual_parser = Feedjira.parser_for_xml(xml)
      expect(actual_parser).to eq Feedjira::Parser::GoogleDocsAtom
    end

    it "with an atom feed it returns the Atom parser" do
      xml = sample_atom_feed
      actual_parser = Feedjira.parser_for_xml(xml)
      expect(actual_parser).to eq Feedjira::Parser::Atom
    end

    it "with an atom feedburner feed it returns the AtomFeedBurner parser" do
      xml = sample_feedburner_atom_feed
      actual_parser = Feedjira.parser_for_xml(xml)
      expect(actual_parser).to eq Feedjira::Parser::AtomFeedBurner
    end

    it "with an rdf feed it returns the RSS parser" do
      xml = sample_rdf_feed
      actual_parser = Feedjira.parser_for_xml(xml)
      expect(actual_parser).to eq Feedjira::Parser::RSS
    end

    it "with an rss feedburner feed it returns the RSSFeedBurner parser" do
      xml = sample_rss_feed_burner_feed
      actual_parser = Feedjira.parser_for_xml(xml)
      expect(actual_parser).to eq Feedjira::Parser::RSSFeedBurner
    end

    it "with an rss 2.0 feed it returns the RSS parser" do
      xml = sample_rss_feed
      actual_parser = Feedjira.parser_for_xml(xml)
      expect(actual_parser).to eq Feedjira::Parser::RSS
    end

    it "with an itunes feed it returns the RSS parser" do
      xml = sample_itunes_feed
      actual_parser = Feedjira.parser_for_xml(xml)
      expect(actual_parser).to eq Feedjira::Parser::ITunesRSS
    end

    context "when parsers are configured" do
      it "does not use default parsers" do
        xml = "Atom asdf"
        new_parser = Class.new do
          def self.able_to_parse?(_)
            true
          end
        end

        Feedjira.configure { |config| config.parsers = [new_parser] }

        parser = Feedjira.parser_for_xml(xml)
        expect(parser).to eq(new_parser)

        Feedjira.reset_configuration!
      end
    end
  end
end
