require 'spec_helper'

module Feedjira::Parser
  describe '#will_parse?' do
    it 'should return true for an itunes RSS feed' do
      expect(ITunesRSS).to be_able_to_parse(sample_itunes_feed)
    end

    it 'should return true for an itunes RSS feed with spaces between attribute names, equals sign, and values' do # rubocop:disable Metrics/LineLength
      expect(ITunesRSS).to be_able_to_parse(sample_itunes_feed_with_spaces)
    end

    it 'should return true for an itunes RSS feed with single-quoted attributes' do # rubocop:disable Metrics/LineLength
      expect(ITunesRSS).to be_able_to_parse(sample_itunes_feed_with_single_quotes)  # rubocop:disable Metrics/LineLength
    end

    it 'should return fase for an atom feed' do
      expect(ITunesRSS).to_not be_able_to_parse(sample_atom_feed)
    end

    it 'should return false for an rss feedburner feed' do
      expect(ITunesRSS).to_not be_able_to_parse(sample_rss_feed_burner_feed)
    end
  end

  describe 'parsing' do
    before(:each) do
      @feed = ITunesRSS.parse(sample_itunes_feed)
    end

    it 'should parse the subtitle' do
      expect(@feed.itunes_subtitle).to eq 'A show about everything'
    end

    it 'should parse the author' do
      expect(@feed.itunes_author).to eq 'John Doe'
    end

    it 'should parse an owner' do
      expect(@feed.itunes_owners.size).to eq 1
    end

    it 'should parse an image' do
      expect(@feed.itunes_image).to eq 'http://example.com/podcasts/everything/AllAboutEverything.jpg'
    end

    it 'should parse categories' do
      expect(@feed.itunes_categories).to eq [
        'Technology',
        'Gadgets',
        'TV & Film',
        'Arts',
        'Design',
        'Food'
      ]

      expect(@feed.itunes_category_paths).to eq [
        %w(Technology Gadgets),
        ['TV & Film'],
        %w(Arts Design),
        %w(Arts Food)
      ]
    end

    it 'should parse the summary' do
      summary = 'All About Everything is a show about everything. Each week we dive into any subject known to man and talk about it as much as we can. Look for our Podcast in the iTunes Music Store' # rubocop:disable Metrics/LineLength
      expect(@feed.itunes_summary).to eq summary
    end

    it 'should parse the complete tag' do
      expect(@feed.itunes_complete).to eq 'yes'
    end

    it 'should parse entries' do
      expect(@feed.entries.size).to eq 3
    end

    it 'should parse the new-feed-url' do
      expect(@feed.itunes_new_feed_url).to eq 'http://example.com/new.xml'
    end
  end
end
