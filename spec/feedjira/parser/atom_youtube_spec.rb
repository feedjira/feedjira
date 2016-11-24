require File.join(File.dirname(__FILE__), %w(.. .. spec_helper))

describe Feedjira::Parser::AtomYoutube do
  describe '#will_parse?' do
    it 'should return true for an atom youtube feed' do
      expect(Feedjira::Parser::AtomYoutube).to be_able_to_parse(sample_youtube_atom_feed) # rubocop:disable Metrics/LineLength
    end

    it 'should return fase for an atom feed' do
      expect(Feedjira::Parser::AtomYoutube).to_not be_able_to_parse(sample_atom_feed) # rubocop:disable Metrics/LineLength
    end

    it 'should return false for an rss feedburner feed' do
      expect(Feedjira::Parser::AtomYoutube).to_not be_able_to_parse(sample_rss_feed_burner_feed) # rubocop:disable Metrics/LineLength
    end
  end

  describe 'parsing' do
    before(:each) do
      @feed = Feedjira::Parser::AtomYoutube.parse(sample_youtube_atom_feed)
    end

    it 'should parse the title' do
      expect(@feed.title).to eq 'Google'
    end

    it 'should parse the author' do
      expect(@feed.author).to eq 'Google Author'
    end

    it 'should parse the url' do
      expect(@feed.url).to eq 'http://www.youtube.com/user/Google'
    end

    it 'should parse the feed_url' do
      expect(@feed.feed_url).to eq 'http://www.youtube.com/feeds/videos.xml?user=google'
    end

    it 'should parse the YouTube channel id' do
      expect(@feed.youtube_channel_id).to eq 'UCK8sQmJBp8GCxrOtXWBpyEA'
    end
  end
end
