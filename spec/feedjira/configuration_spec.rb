require 'spec_helper'

describe Feedjira::Configuration do
  describe '.configure' do
    it 'sets follow_redirect_limit config' do
      Feedjira.configure { |config| config.follow_redirect_limit = 10 }
      expect(Feedjira.follow_redirect_limit).to eq(10)
    end

    it 'sets request_timeout config' do
      Feedjira.configure { |config| config.request_timeout = 45 }
      expect(Feedjira.request_timeout).to eq(45)
    end

    it 'sets strip_whitespace config' do
      Feedjira.configure { |config| config.strip_whitespace = true }
      expect(Feedjira.strip_whitespace).to be true
    end

    it 'sets user_agent config' do
      Feedjira.configure { |config| config.user_agent = 'Test User Agent' }
      expect(Feedjira.user_agent).to eq('Test User Agent')
    end
  end
end
