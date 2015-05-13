require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::AtomYoutubeEntry do
  describe 'parsing' do
    before do
      @feed = Feedjira::Parser::AtomYoutube.parse(sample_youtube_atom_feed)
      @entry = @feed.entries.first
    end

    it 'should have the summary populated from the media:description element' do
      expect(@entry.summary).to eq 'A question is the most powerful force in the world. It can start you on an adventure or spark a connection. See where a question can take you. The Google app is available on iOS and Android. Download the app here: http://www.google.com/search/about/download'
    end

    it 'should have the custom youtube video id' do
      expect(@entry.youtube_video_id).to eq '5shykyfmb28'
    end

    it 'should have the custom media title' do
      expect(@entry.media_title).to eq 'The Google app: Questions'
    end

    it 'should have the custom media url' do
      expect(@entry.media_url).to eq 'https://www.youtube.com/v/5shykyfmb28?version=3'
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
      expect(@entry.media_thumbnail_url).to eq 'https://i2.ytimg.com/vi/5shykyfmb28/hqdefault.jpg'
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
