
CWD = File.dirname(__FILE__)

require File.expand_path(CWD + '/../lib/feedjira')
require 'sample_feeds'

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

SAXMachine.handler = ENV['HANDLER'].to_sym if ENV['HANDLER']

RSpec.configure do |c|
  c.include SampleFeeds

  c.before(:each) do
    stub_request(:get, /example\.com/)
      .to_return(status: 500, body: '') # simulate fetch fails
    stub_request(:get, /feedjira\.com$/)
      .to_return(status: 200, body: File.read(CWD + '/sample_feeds/index.html'))
    stub_request(:get, /feedjira\.com\/blog\/feed\.xml/)
      .to_return(status: 200, body: File.read(CWD + '/sample_feeds/FeedjiraBlog.xml'),
                 headers: { 'etag' => '"a20cd-393e-517c9e38bab40"',
                            'last-modified' => 'Fri, 05 Jun 2015 18:59:17 GMT' })
  end
end
