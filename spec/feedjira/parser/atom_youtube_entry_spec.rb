require File.join(File.dirname(__FILE__), %w(.. .. spec_helper))

describe Feedjira::Parser::AtomYoutubeEntry do
  describe 'parsing' do
    before do
      @feed = Feedjira::Parser::AtomYoutube.parse(sample_youtube_atom_feed)
      @entry = @feed.entries.first
    end

    it 'should have the title' do
      expect(@entry.title).to eq 'The Google app: Questions Title'
    end

    it 'should have the url' do
      expect(@entry.url).to eq 'http://www.youtube.com/watch?v=5shykyfmb28'
    end

    it 'should have the entry id' do
      expect(@entry.entry_id).to eq 'yt:video:5shykyfmb28'
    end

    it 'should have the published date' do
      expect(@entry.published).to eq Time.parse_safely('2015-05-04T00:01:27+00:00') # rubocop:disable Metrics/LineLength
    end

    it 'should have the updated date' do
      expect(@entry.updated).to eq Time.parse_safely('2015-05-13T17:38:30+00:00') # rubocop:disable Metrics/LineLength
    end

    it 'should have the content populated from the media:description element' do
      expect(@entry.content).to eq 'A question is the most powerful force in the world. It can start you on an adventure or spark a connection. See where a question can take you. The Google app is available on iOS and Android. Download the app here: http://www.google.com/search/about/download' # rubocop:disable Metrics/LineLength
    end

    it 'should have the summary but blank' do
      expect(@entry.summary).to be_nil
    end

    it 'should have the custom youtube video id' do
      expect(@entry.youtube_video_id).to eq '5shykyfmb28'
    end

    it 'should have the custom media title' do
      expect(@entry.media_title).to eq 'The Google app: Questions'
    end

    it 'should have the custom media url' do
      expect(@entry.media_url).to eq 'https://www.youtube.com/v/5shykyfmb28?version=3' # rubocop:disable Metrics/LineLength
    end

    it 'should have the custom media type' do
      expect(@entry.media_type).to eq 'application/x-shockwave-flash'
    end

    it 'should have the custom media width' do
      expect(@entry.media_width).to eq '640'
    end

    it 'should have the custom media height' do
      expect(@entry.media_height).to eq '390'
    end

    it 'should have the custom media thumbnail url' do
      expect(@entry.media_thumbnail_url).to eq 'https://i2.ytimg.com/vi/5shykyfmb28/hqdefault.jpg' # rubocop:disable Metrics/LineLength
    end

    it 'should have the custom media thumbnail width' do
      expect(@entry.media_thumbnail_width).to eq '480'
    end

    it 'should have the custom media thumbnail height' do
      expect(@entry.media_thumbnail_height).to eq '360'
    end

    it 'should have the custom media star count' do
      expect(@entry.media_star_count).to eq '3546'
    end

    it 'should have the custom media star average' do
      expect(@entry.media_star_average).to eq '4.79'
    end

    it 'should have the custom media views' do
      expect(@entry.media_views).to eq '251497'
    end
  end
end
