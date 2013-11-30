require 'benchmark'
require 'net/http'
require 'curb'

urls = ['http://www.google.com'] * 100

Benchmark.bm(11) do |b|
  b.report('Net::HTTP') do
    urls.each do |url|
      Net::HTTP.get URI.parse url
    end
  end

  b.report('Curl::Easy') do
    urls.each do |url|
      Curl::Easy.perform url
    end
  end

  b.report('Curl::Multi') do
    Curl::Multi.get urls
  end
end
