require 'spec_helper'

describe Feedjira::Parser::RSS do
  describe '#will_parse?' do
    it 'should return true for an RSS feed' do
      expect(Feedjira::Parser::RSS).to be_able_to_parse(sample_rss_feed)
    end

    it 'should return false for an atom feed' do
      expect(Feedjira::Parser::RSS).to_not be_able_to_parse(sample_atom_feed)
    end

    it 'should return false for an rss feedburner feed' do
      able = Feedjira::Parser::RSS.able_to_parse? sample_rss_feed_burner_feed
      expect(able).to eq false
    end
  end

  describe 'parsing' do
    before(:each) do
      @feed = Feedjira::Parser::RSS.parse(sample_rss_feed)
    end

    it 'should parse the version' do
      expect(@feed.version).to eq '2.0'
    end

    it 'should parse the title' do
      expect(@feed.title).to eq 'Tender Lovemaking'
    end

    it 'should parse the description' do
      expect(@feed.description).to eq 'The act of making love, tenderly.'
    end

    it 'should parse the url' do
      expect(@feed.url).to eq 'http://tenderlovemaking.com'
    end

    it 'should parse the ttl' do
      expect(@feed.ttl).to eq '60'
    end

    it 'should parse the last build date' do
      expect(@feed.last_built).to eq 'Sat, 07 Sep 2002 09:42:31 GMT'
    end

    it 'should parse the hub urls' do
      expect(@feed.hubs.count).to eq 1
      expect(@feed.hubs.first).to eq 'http://pubsubhubbub.appspot.com/'
    end

    it 'should provide an accessor for the feed_url' do
      expect(@feed).to respond_to :feed_url
      expect(@feed).to respond_to :feed_url=
    end

    it 'should parse the language' do
      expect(@feed.language).to eq 'en'
    end

    it 'should parse the image url' do
      expect(@feed.image.url).to eq 'https://tenderlovemaking.com/images/header-logo-text-trimmed.png'
    end

    it 'should parse the image title' do
      expect(@feed.image.title).to eq 'Tender Lovemaking'
    end

    it 'should parse the image link' do
      expect(@feed.image.link).to eq 'http://tenderlovemaking.com'
    end

    it 'should parse the image width' do
      expect(@feed.image.width).to eq '766'
    end

    it 'should parse the image height' do
      expect(@feed.image.height).to eq '138'
    end

    it 'should parse the image description' do
      expect(@feed.image.description).to eq 'The act of making love, tenderly.'
    end

    it 'should parse entries' do
      expect(@feed.entries.size).to eq 10
    end
  end
end
