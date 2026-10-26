# frozen_string_literal: true

require "spec_helper"
require "tempfile"

::RSpec.describe(::Feedjira::SAXNokogiriHandlerPatch) do
  around do |example|
    original_handler = ::SAXMachine.handler
    ::SAXMachine.handler = :nokogiri
    example.run
  ensure
    ::SAXMachine.handler = original_handler
  end

  def rss_with_entry(title: "Title", link: "https://example.com", doctype: "")
    <<~XML
      <?xml version="1.0"?>
      #{doctype}
      <rss version="2.0">
        <channel>
          <title>Feed</title>
          <item>
            <title>#{title}</title>
            <enclosure url="#{link}" type="audio/mpeg"/>
          </item>
        </channel>
      </rss>
    XML
  end

  it "does not load external entities" do
    secret = ::Tempfile.new
    secret.write("secret contents")
    secret.flush
    doctype = %(<!DOCTYPE rss [<!ENTITY file SYSTEM "file://#{secret.path}">]>)

    feed = ::Feedjira.parse(rss_with_entry(title: "&file;", doctype:))

    expect(feed.entries.first.title.to_s).not_to(include("secret contents"))
  ensure
    secret.close!
  end

  it "decodes predefined entities and character references in text" do
    feed = ::Feedjira.parse(rss_with_entry(title: "a &amp; b &lt; c &#8217;"))

    expect(feed.entries.first.title).to(eq("a & b < c ’"))
  end

  it "expands internal entities in text" do
    doctype = '<!DOCTYPE rss [<!ENTITY co "Acme Inc">]>'

    feed = ::Feedjira.parse(rss_with_entry(title: "by &co;", doctype:))

    expect(feed.entries.first.title).to(eq("by Acme Inc"))
  end

  it "decodes ampersands in attribute values" do
    xml = rss_with_entry(link: "https://example.com/?a=1&amp;b=2&amp;c=&amp;#38;")

    feed = ::Feedjira.parse(xml, parser: ::Feedjira::Parser::ITunesRSS)

    expect(feed.entries.first.enclosure_url).to(eq("https://example.com/?a=1&b=2&c=&#38;"))
  end
end
