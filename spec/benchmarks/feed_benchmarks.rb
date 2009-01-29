# this is some spike code to compare the speed of different methods for performing
# multiple feed fetches
require 'rubygems'
require 'curb'
require 'activesupport'

urls = ["http://feeds.feedburner.com/PaulDixExplainsNothing"]
multi = Curl::Multi.new
urls.each do |url|
  easy = Curl::Easy.new(url) do |curl|
    curl.headers["User-Agent"] = "feedzirra"
#    curl.headers["If-Modified-Since"] = Time.now.httpdate
#    curl.headers["If-None-Match"] = "ziEyTl4q9GH04BR4jgkImd0GvSE"
    curl.follow_location = true
    curl.on_success do |c|
      puts c.header_str.inspect
      puts c.response_code
      puts c.body_str.slice(0, 1000)
    end
    curl.on_failure do |c|
      puts c.response_code
    end
  end
  multi.add(easy)
end

multi.perform