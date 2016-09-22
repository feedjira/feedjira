require 'spec_helper'

module Feedjira::Parser
  describe '#will_parse?' do
    it 'should return true for an atom feed' do
      expect(Atom).to be_able_to_parse(sample_atom_feed)
    end

    it 'should return false for an rdf feed' do
      expect(Atom).to_not be_able_to_parse(sample_rdf_feed)
    end

    it 'should return false for an rss feedburner feed' do
      expect(Atom).to_not be_able_to_parse(sample_rss_feed_burner_feed)
    end

    it 'should return true for an atom feed that has line breaks in between attributes in the <feed> node' do # rubocop:disable Metrics/LineLength
      expect(Atom).to be_able_to_parse(sample_atom_feed_line_breaks)
    end
  end

  describe 'parsing' do
    before(:each) do
      @feed = Atom.parse(sample_atom_feed)
    end

    it 'should parse the title' do
      expect(@feed.title).to eq 'Amazon Web Services Blog'
    end

    it 'should parse the description' do
      description = 'Amazon Web Services, Products, Tools, and Developer Information...' # rubocop:disable Metrics/LineLength
      expect(@feed.description).to eq description
    end

    it 'should parse the url' do
      expect(@feed.url).to eq 'http://aws.typepad.com/aws/'
    end

    it "should parse the url even when it doesn't have the type='text/html' attribute" do # rubocop:disable Metrics/LineLength
      xml = load_sample 'atom_with_link_tag_for_url_unmarked.xml'
      feed = Atom.parse xml
      expect(feed.url).to eq 'http://www.innoq.com/planet/'
    end

    it "should parse the feed_url even when it doesn't have the type='application/atom+xml' attribute" do # rubocop:disable Metrics/LineLength
      feed = Atom.parse(load_sample('atom_with_link_tag_for_url_unmarked.xml'))
      expect(feed.feed_url).to eq 'http://www.innoq.com/planet/atom.xml'
    end

    it 'should parse the feed_url' do
      expect(@feed.feed_url).to eq 'http://aws.typepad.com/aws/atom.xml'
    end

    it 'should parse no hub urls' do
      expect(@feed.hubs.count).to eq 0
    end

    it 'should parse the hub urls' do
      feed_with_hub = Atom.parse(load_sample('SamRuby.xml'))
      expect(feed_with_hub.hubs.count).to eq 1
      expect(feed_with_hub.hubs.first).to eq 'http://pubsubhubbub.appspot.com/'
    end

    it 'should parse entries' do
      expect(@feed.entries.size).to eq 10
    end
  end

  describe 'preprocessing' do
    it 'retains markup in xhtml content' do
      Atom.preprocess_xml = true

      feed = Atom.parse sample_atom_xhtml_feed
      entry = feed.entries.first

      expect(entry.title).to match(/\<i/)
      expect(entry.summary).to match(/\<b/)
      expect(entry.content).to match(/\A\<p/)
    end

    it 'should not duplicate content when there are divs in content' do
      Atom.preprocess_xml = true

      feed = Atom.parse sample_duplicate_content_atom_feed
      content = Nokogiri::HTML(feed.entries[1].content)
      expect(content.css('img').length).to eq 11
    end
  end

  describe 'parsing url and feed url based on rel attribute' do
    before :each do
      @feed = Atom.parse(sample_atom_middleman_feed)
    end

    it 'should parse url' do
      expect(@feed.url).to eq 'http://feedjira.com/blog'
    end

    it 'should parse feed url' do
      expect(@feed.feed_url).to eq 'http://feedjira.com/blog/feed.xml'
    end
  end
end
