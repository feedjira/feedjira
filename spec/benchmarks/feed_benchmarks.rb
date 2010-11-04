# this is some spike code to compare the speed of different methods for performing
# multiple feed fetches
require 'rubygems'
require 'curb'
require 'active_support'

require 'net/http'
require 'uri'

require 'benchmark'
include Benchmark

GET_COUNT = 1
urls = ["http://www.pauldix.net"] * GET_COUNT


benchmark do |t|
  t.report("taf2-curb") do
    multi = Curl::Multi.new
    urls.each do |url|
      easy = Curl::Easy.new(url) do |curl|
        curl.headers["User-Agent"] = "feedzirra"
    #    curl.headers["If-Modified-Since"] = Time.now.httpdate
    #    curl.headers["If-None-Match"] = "ziEyTl4q9GH04BR4jgkImd0GvSE"
        curl.follow_location = true
        curl.on_success do |c|
    #      puts c.header_str.inspect
#          puts c.response_code
    #      puts c.body_str.slice(0, 500)
        end
        curl.on_failure do |c|
          puts "**** #{c.response_code}"
        end
      end
      multi.add(easy)
    end

    multi.perform
  end

  t.report("nethttp") do
    urls.each do |url|
      res = Net::HTTP.get(URI.parse(url))
#      puts res.slice(0, 500)
    end
  end
  
  require 'rfuzz/session'
  include RFuzz 
  t.report("rfuzz") do
    GET_COUNT.times do
      http = HttpClient.new("www.pauldix.net", 80)
      response = http.get("/")
      if response.http_status != "200" 
        puts "***** #{response.http_status}"
      else
#        puts response.http_status
  #      puts response.http_body.slice(0, 500)
      end
    end
  end
  
  require 'eventmachine'
  t.report("eventmachine") do
    counter = GET_COUNT
    EM.run do
      GET_COUNT.times do
        http = EM::Protocols::HttpClient2.connect("www.pauldix.net", 80)
        request = http.get("/")
        request.callback do
#          puts request.status
#          puts request.content.slice(0, 500)
          counter -= 1
          EM.stop if counter == 0
        end
      end
    end
  end
  
  
  require 'curl-multi'
  t.report("curl multi") do
    multi = Curl::Multi.new
    urls.each do |url|
      on_failure = lambda do |ex|
        puts "****** Failed to retrieve #{url}"
      end

      on_success = lambda do |body|
#        puts "got #{url}"
#        puts body.slice(0, 500)
      end
      multi.get(url, on_success, on_failure)
    end

    multi.select([], []) while multi.size > 0
  end
end