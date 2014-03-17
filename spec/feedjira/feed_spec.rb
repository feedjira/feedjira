require File.dirname(__FILE__) + '/../spec_helper'

class Hell < StandardError; end

class FailParser
  def self.parse(_, &on_failure)
    on_failure.call 'this parser always fails.'
  end
end

describe Feedjira::Feed do

  describe "#add_common_feed_element" do
    before(:all) do
      Feedjira::Feed.add_common_feed_element("generator")
    end

    it "should parse the added element out of Atom feeds" do
      Feedjira::Feed.parse(sample_wfw_feed).generator.should == "TypePad"
    end

    it "should parse the added element out of Atom Feedburner feeds" do
      Feedjira::Parser::Atom.new.should respond_to(:generator)
    end

    it "should parse the added element out of RSS feeds" do
      Feedjira::Parser::RSS.new.should respond_to(:generator)
    end
  end

  describe "#add_common_feed_entry_element" do
    before(:all) do
      Feedjira::Feed.add_common_feed_entry_element("wfw:commentRss", :as => :comment_rss)
    end

    it "should parse the added element out of Atom feeds entries" do
      Feedjira::Feed.parse(sample_wfw_feed).entries.first.comment_rss.should == "this is the new val"
    end

    it "should parse the added element out of Atom Feedburner feeds entries" do
      Feedjira::Parser::AtomEntry.new.should respond_to(:comment_rss)
    end

    it "should parse the added element out of RSS feeds entries" do
      Feedjira::Parser::RSSEntry.new.should respond_to(:comment_rss)
    end
  end

  describe '#parse_with' do
    let(:xml) { '<xml></xml>' }

    it 'invokes the parser and passes the xml' do
      parser = double 'Parser', parse: nil
      parser.should_receive(:parse).with xml
      Feedjira::Feed.parse_with parser, xml
    end

    context 'with a callback block' do
      it 'passes the callback to the parser' do
        callback = ->(*) { raise Hell }

        expect do
          Feedjira::Feed.parse_with FailParser, xml, &callback
        end.to raise_error Hell
      end
    end
  end

  describe "#parse" do # many of these tests are redundant with the specific feed type tests, but I put them here for completeness
    context "when there's an available parser" do
      it "should parse an rdf feed" do
        feed = Feedjira::Feed.parse(sample_rdf_feed)
        feed.title.should == "HREF Considered Harmful"
        feed.entries.first.published.should == Time.parse_safely("Tue Sep 02 19:50:07 UTC 2008")
        feed.entries.size.should == 10
      end

      it "should parse an rss feed" do
        feed = Feedjira::Feed.parse(sample_rss_feed)
        feed.title.should == "Tender Lovemaking"
        feed.entries.first.published.should == Time.parse_safely("Thu Dec 04 17:17:49 UTC 2008")
        feed.entries.size.should == 10
      end

      it "should parse an atom feed" do
        feed = Feedjira::Feed.parse(sample_atom_feed)
        feed.title.should == "Amazon Web Services Blog"
        feed.entries.first.published.should == Time.parse_safely("Fri Jan 16 18:21:00 UTC 2009")
        feed.entries.size.should == 10
      end

      it "should parse an feedburner atom feed" do
        feed = Feedjira::Feed.parse(sample_feedburner_atom_feed)
        feed.title.should == "Paul Dix Explains Nothing"
        feed.entries.first.published.should == Time.parse_safely("Thu Jan 22 15:50:22 UTC 2009")
        feed.entries.size.should == 5
      end

      it "should parse an itunes feed" do
        feed = Feedjira::Feed.parse(sample_itunes_feed)
        feed.title.should == "All About Everything"
        feed.entries.first.published.should == Time.parse_safely("Wed, 15 Jun 2005 19:00:00 GMT")
        feed.entries.size.should == 3
      end
    end

    context "when there's no available parser" do
      it "raises Feedjira::NoParserAvailable" do
        proc {
          Feedjira::Feed.parse("I'm an invalid feed")
        }.should raise_error(Feedjira::NoParserAvailable)
      end
    end

    it "should parse an feedburner rss feed" do
      feed = Feedjira::Feed.parse(sample_rss_feed_burner_feed)
      feed.title.should == "TechCrunch"
      feed.entries.first.published.should == Time.parse_safely("Wed Nov 02 17:25:27 UTC 2011")
      feed.entries.size.should == 20
    end
  end

  describe "#determine_feed_parser_for_xml" do
    it 'should return the Feedjira::Parser::GoogleDocsAtom calss for a Google Docs atom feed' do
      Feedjira::Feed.determine_feed_parser_for_xml(sample_google_docs_list_feed).should == Feedjira::Parser::GoogleDocsAtom
    end

    it "should return the Feedjira::Parser::Atom class for an atom feed" do
      Feedjira::Feed.determine_feed_parser_for_xml(sample_atom_feed).should == Feedjira::Parser::Atom
    end

    it "should return the Feedjira::Parser::AtomFeedBurner class for an atom feedburner feed" do
      Feedjira::Feed.determine_feed_parser_for_xml(sample_feedburner_atom_feed).should == Feedjira::Parser::AtomFeedBurner
    end

    it "should return the Feedjira::Parser::RSS class for an rdf/rss 1.0 feed" do
      Feedjira::Feed.determine_feed_parser_for_xml(sample_rdf_feed).should == Feedjira::Parser::RSS
    end

    it "should return the Feedjira::Parser::RSSFeedBurner class for an rss feedburner feed" do
      Feedjira::Feed.determine_feed_parser_for_xml(sample_rss_feed_burner_feed).should == Feedjira::Parser::RSSFeedBurner
    end

    it "should return the Feedjira::Parser::RSS object for an rss 2.0 feed" do
      Feedjira::Feed.determine_feed_parser_for_xml(sample_rss_feed).should == Feedjira::Parser::RSS
    end

    it "should return a Feedjira::Parser::RSS object for an itunes feed" do
      Feedjira::Feed.determine_feed_parser_for_xml(sample_itunes_feed).should == Feedjira::Parser::ITunesRSS
    end

  end

  describe "#setup_easy" do
    class MockCurl
      attr_accessor :follow_location, :userpwd, :proxy_url, :proxy_port, :max_redirects, :timeout, :ssl_verify_host, :ssl_verify_peer, :ssl_version, :enable_cookies, :cookiefile, :cookies

      def headers
        @headers ||= {}
      end
    end

    let(:curl) { MockCurl.new }

    it "sets defaults on curl" do
      Feedjira::Feed.setup_easy curl

      curl.headers["User-Agent"].should eq Feedjira::Feed::USER_AGENT
      curl.follow_location.should eq true
    end

    it "allows user agent over-ride" do
      Feedjira::Feed.setup_easy(curl, user_agent: '007')
      curl.headers["User-Agent"].should eq '007'
    end

    it "allows to set language" do
      Feedzirra::Feed.setup_easy(curl, language: 'en-US')
      curl.headers["Accept-Language"].should eq 'en-US'
    end

    it "enables compression" do
      Feedjira::Feed.setup_easy(curl, compress: true)
      curl.headers["Accept-encoding"].should eq 'gzip, deflate'
    end

    it "enables compression even when you act like you don't want it" do
      Feedjira::Feed.setup_easy(curl, compress: false)
      curl.headers["Accept-encoding"].should eq 'gzip, deflate'
    end

    it "sets up http auth" do
      Feedjira::Feed.setup_easy(curl, http_authentication: ['user', 'pass'])
      curl.userpwd.should eq 'user:pass'
    end

    it "passes known options to curl" do
      known_options = {
        enable_cookies: true,
        cookiefile: 'cookies.txt',
        cookies: 'asdf',
        proxy_url: 'http://proxy.url.com',
        proxy_port: '1234',
        max_redirects: 2,
        timeout: 500,
        ssl_verify_host: true,
        ssl_verify_peer: true,
        ssl_version: :omg
      }

      Feedjira::Feed.setup_easy curl, known_options

      known_options.each do |option|
        key, value = option
        curl.send(key).should eq value
      end
    end

    it "ignores unknown options" do
      expect { Feedjira::Feed.setup_easy curl, foo: :bar }.to_not raise_error
    end
  end

  describe "when adding feed types" do
    it "should prioritize added types over the built in ones" do
      feed_text = "Atom asdf"
      Feedjira::Parser::Atom.stub(:able_to_parse?).and_return(true)
      new_feed_type = Class.new do
        def self.able_to_parse?(val)
          true
        end
      end

      new_feed_type.should be_able_to_parse(feed_text)
      Feedjira::Feed.add_feed_class(new_feed_type)
      Feedjira::Feed.determine_feed_parser_for_xml(feed_text).should == new_feed_type

      # this is a hack so that this doesn't break the rest of the tests
      Feedjira::Feed.feed_classes.reject! {|o| o == new_feed_type }
    end
  end

  describe '#etag_from_header' do
    before(:each) do
      @header = "HTTP/1.0 200 OK\r\nDate: Thu, 29 Jan 2009 03:55:24 GMT\r\nServer: Apache\r\nX-FB-Host: chi-write6\r\nLast-Modified: Wed, 28 Jan 2009 04:10:32 GMT\r\nETag: ziEyTl4q9GH04BR4jgkImd0GvSE\r\nP3P: CP=\"ALL DSP COR NID CUR OUR NOR\"\r\nConnection: close\r\nContent-Type: text/xml;charset=utf-8\r\n\r\n"
    end

    it "should return the etag from the header if it exists" do
      Feedjira::Feed.etag_from_header(@header).should == "ziEyTl4q9GH04BR4jgkImd0GvSE"
    end

    it "should return nil if there is no etag in the header" do
      Feedjira::Feed.etag_from_header("foo").should be_nil
    end

  end

  describe '#last_modified_from_header' do
    before(:each) do
      @header = "HTTP/1.0 200 OK\r\nDate: Thu, 29 Jan 2009 03:55:24 GMT\r\nServer: Apache\r\nX-FB-Host: chi-write6\r\nLast-Modified: Wed, 28 Jan 2009 04:10:32 GMT\r\nETag: ziEyTl4q9GH04BR4jgkImd0GvSE\r\nP3P: CP=\"ALL DSP COR NID CUR OUR NOR\"\r\nConnection: close\r\nContent-Type: text/xml;charset=utf-8\r\n\r\n"
    end

    it "should return the last modified date from the header if it exists" do
      Feedjira::Feed.last_modified_from_header(@header).should == Time.parse_safely("Wed, 28 Jan 2009 04:10:32 GMT")
    end

    it "should return nil if there is no last modified date in the header" do
      Feedjira::Feed.last_modified_from_header("foo").should be_nil
    end
  end

  describe "fetching feeds" do
    before(:each) do
      @paul_feed = { :xml => load_sample("PaulDixExplainsNothing.xml"), :url => "http://feeds.feedburner.com/PaulDixExplainsNothing" }
      @trotter_feed = { :xml => load_sample("TrotterCashionHome.xml"), :url => "http://feeds2.feedburner.com/trottercashion" }
      @invalid_feed = { :xml => 'This feed is invalid', :url => "http://feeds.feedburner.com/InvalidFeed" }
    end

    describe "#fetch_raw" do
      before(:each) do
        @cmock = double('cmock', :header_str => '', :body_str => @paul_feed[:xml] )
        @multi = double('curl_multi', :add => true, :perform => true)
        @curl_easy = double('curl_easy')
        @curl = double('curl', :headers => {}, :follow_location= => true, :on_failure => true, :on_complete => true)
        @curl.stub(:on_success).and_yield(@cmock)

        Curl::Multi.stub(:new).and_return(@multi)
        Curl::Easy.stub(:new).and_yield(@curl).and_return(@curl_easy)
      end

      it "should set user agent if it's passed as an option" do
        Feedjira::Feed.fetch_raw(@paul_feed[:url], :user_agent => 'Custom Useragent')
        @curl.headers['User-Agent'].should == 'Custom Useragent'
      end

      it "should set user agent to default if it's not passed as an option" do
        Feedjira::Feed.fetch_raw(@paul_feed[:url])
        @curl.headers['User-Agent'].should == Feedjira::Feed::USER_AGENT
      end

      it "should set if modified since as an option if passed" do
        Feedjira::Feed.fetch_raw(@paul_feed[:url], :if_modified_since => Time.parse_safely("Wed, 28 Jan 2009 04:10:32 GMT"))
        @curl.headers["If-Modified-Since"].should == 'Wed, 28 Jan 2009 04:10:32 GMT'
      end

      it "should set if none match as an option if passed" do
        Feedjira::Feed.fetch_raw(@paul_feed[:url], :if_none_match => 'ziEyTl4q9GH04BR4jgkImd0GvSE')
        @curl.headers["If-None-Match"].should == 'ziEyTl4q9GH04BR4jgkImd0GvSE'
      end

      it 'should set userpwd for http basic authentication if :http_authentication is passed' do
        @curl.should_receive(:userpwd=).with('username:password')
        Feedjira::Feed.fetch_raw(@paul_feed[:url], :http_authentication => ['username', 'password'])
      end

      it 'should set accepted encodings' do
        Feedjira::Feed.fetch_raw(@paul_feed[:url], :compress => true)
        @curl.headers["Accept-encoding"].should == 'gzip, deflate'
      end

      it "should return raw xml" do
        Feedjira::Feed.fetch_raw(@paul_feed[:url]).should =~ /^#{Regexp.escape('<?xml version="1.0" encoding="UTF-8"?>')}/
      end

      it "should take multiple feed urls and return a hash of urls and response xml" do
        multi = double('curl_multi', :add => true, :perform => true)
        Curl::Multi.stub(:new).and_return(multi)

        paul_response = double('paul_response', :header_str => '', :body_str => @paul_feed[:xml] )
        trotter_response = double('trotter_response', :header_str => '', :body_str => @trotter_feed[:xml] )

        paul_curl = double('paul_curl', :headers => {}, :follow_location= => true, :on_failure => true, :on_complete => true)
        paul_curl.stub(:on_success).and_yield(paul_response)

        trotter_curl = double('trotter_curl', :headers => {}, :follow_location= => true, :on_failure => true, :on_complete => true)
        trotter_curl.stub(:on_success).and_yield(trotter_response)

        Curl::Easy.should_receive(:new).with(@paul_feed[:url]).ordered.and_yield(paul_curl)
        Curl::Easy.should_receive(:new).with(@trotter_feed[:url]).ordered.and_yield(trotter_curl)

        results = Feedjira::Feed.fetch_raw([@paul_feed[:url], @trotter_feed[:url]])
        results.keys.should include(@paul_feed[:url])
        results.keys.should include(@trotter_feed[:url])
        results[@paul_feed[:url]].should =~ /Paul Dix/
        results[@trotter_feed[:url]].should =~ /Trotter Cashion/
      end

      it "should always return a hash when passed an array" do
        results = Feedjira::Feed.fetch_raw([@paul_feed[:url]])
        results.class.should == Hash
      end
    end

    describe "#add_url_to_multi" do
      before(:each) do
        allow_message_expectations_on_nil
        @multi = Curl::Multi.get([@paul_feed[:url]], {:follow_location => true}, {:pipeline => true})
        @multi.stub(:add)
        @easy_curl = Curl::Easy.new(@paul_feed[:url])

        Curl::Easy.should_receive(:new).and_yield(@easy_curl)
      end

      it "should set user agent if it's passed as an option" do
        Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, :user_agent => 'My cool application')
        @easy_curl.headers["User-Agent"].should == 'My cool application'
      end

      it "should set user agent to default if it's not passed as an option" do
        Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {})
        @easy_curl.headers["User-Agent"].should == Feedjira::Feed::USER_AGENT
      end

      it "should set if modified since as an option if passed" do
        Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, :if_modified_since => Time.parse_safely("Jan 25 2009 04:10:32 GMT"))
        @easy_curl.headers["If-Modified-Since"].should == 'Sun, 25 Jan 2009 04:10:32 GMT'
      end

      it 'should set follow location to true' do
        @easy_curl.should_receive(:follow_location=).with(true)
        Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {})
      end

      it 'should set userpwd for http basic authentication if :http_authentication is passed' do
        Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, :http_authentication => ['myusername', 'mypassword'])
        @easy_curl.userpwd.should == 'myusername:mypassword'
      end

      it 'should set accepted encodings' do
        Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {:compress => true})
        @easy_curl.headers["Accept-encoding"].should == 'gzip, deflate'
      end

      it "should set if_none_match as an option if passed" do
        Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, :if_none_match => 'ziEyTl4q9GH04BR4jgkImd0GvSE')
        @easy_curl.headers["If-None-Match"].should == 'ziEyTl4q9GH04BR4jgkImd0GvSE'
      end

      describe 'on success' do
        before(:each) do
          @feed = double('feed', :feed_url= => true, :etag= => true, :last_modified= => true)
          Feedjira::Feed.stub(:decode_content).and_return(@paul_feed[:xml])
          Feedjira::Feed.stub(:determine_feed_parser_for_xml).and_return(Feedjira::Parser::AtomFeedBurner)
          Feedjira::Parser::AtomFeedBurner.stub(:parse).and_return(@feed)
          Feedjira::Feed.stub(:etag_from_header).and_return('ziEyTl4q9GH04BR4jgkImd0GvSE')
          Feedjira::Feed.stub(:last_modified_from_header).and_return('Wed, 28 Jan 2009 04:10:32 GMT')
        end

        it 'should decode the response body' do
          Feedjira::Feed.should_receive(:decode_content).with(@easy_curl).and_return(@paul_feed[:xml])
          Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {})
          @easy_curl.on_success.call(@easy_curl)
        end

        it 'should determine the xml parser class' do
          Feedjira::Feed.should_receive(:determine_feed_parser_for_xml).with(@paul_feed[:xml]).and_return(Feedjira::Parser::AtomFeedBurner)
          Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {})
          @easy_curl.on_success.call(@easy_curl)
        end

        it 'should parse the xml' do
          Feedjira::Parser::AtomFeedBurner.should_receive(:parse).
            with(@paul_feed[:xml]).and_return(@feed)
          Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {})
          @easy_curl.on_success.call(@easy_curl)
        end

        describe 'when a compatible xml parser class is found' do
          it 'should set the last effective url to the feed url' do
            @easy_curl.should_receive(:last_effective_url).and_return(@paul_feed[:url])
            @feed.should_receive(:feed_url=).with(@paul_feed[:url])
            Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {})
            @easy_curl.on_success.call(@easy_curl)
          end

          it 'should set the etags on the feed' do
            @feed.should_receive(:etag=).with('ziEyTl4q9GH04BR4jgkImd0GvSE')
            Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {})
            @easy_curl.on_success.call(@easy_curl)
          end

          it 'should set the last modified on the feed' do
            @feed.should_receive(:last_modified=).with('Wed, 28 Jan 2009 04:10:32 GMT')
            Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, {})
            @easy_curl.on_success.call(@easy_curl)
          end

          it 'should add the feed to the responses' do
            responses = {}
            Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], responses, {})
            @easy_curl.on_success.call(@easy_curl)

            responses.length.should == 1
            responses['http://feeds.feedburner.com/PaulDixExplainsNothing'].should == @feed
          end

          it 'should call proc if :on_success option is passed' do
            success = lambda { |url, feed| }
            success.should_receive(:call).with(@paul_feed[:url], @feed)
            Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, { :on_success => success })
            @easy_curl.on_success.call(@easy_curl)
          end

          describe 'when the parser raises an exception' do
            it 'invokes the on_failure callback with that exception' do
              failure = double 'Failure callback', arity: 2
              failure.should_receive(:call).with(@easy_curl, an_instance_of(Hell))

              Feedjira::Parser::AtomFeedBurner.should_receive(:parse).and_raise Hell
              Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, { on_failure: failure })

              @easy_curl.on_success.call(@easy_curl)
            end
          end

          describe 'when the parser invokes its on_failure callback' do
            before(:each) do
              Feedjira::Feed.stub(:determine_feed_parser_for_xml).and_return FailParser
            end

            it 'invokes the on_failure callback' do
              failure = double 'Failure callback', arity: 2
              failure.should_receive(:call).with(@easy_curl, an_instance_of(RuntimeError))

              Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, { on_failure: failure })
              @easy_curl.on_success.call(@easy_curl)
            end
          end
        end

        describe 'when no compatible xml parser class is found' do
          it 'invokes the on_failure callback' do
            failure = double 'Failure callback', arity: 2
            failure.should_receive(:call).with(@easy_curl, "Can't determine a parser")

            Feedjira::Feed.should_receive(:determine_feed_parser_for_xml).and_return nil
            Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, { on_failure: failure })

            @easy_curl.on_success.call(@easy_curl)
          end
        end
      end

      describe 'on failure' do
        before(:each) do
          @headers = "HTTP/1.0 500 Something Bad\r\nDate: Thu, 29 Jan 2009 03:55:24 GMT\r\nServer: Apache\r\nX-FB-Host: chi-write6\r\nLast-Modified: Wed, 28 Jan 2009 04:10:32 GMT\r\n"
          @body = 'Sorry, something broke'

          @easy_curl.stub(:response_code).and_return(500)
          @easy_curl.stub(:header_str).and_return(@headers)
          @easy_curl.stub(:body_str).and_return(@body)
        end

        it 'should call proc if :on_failure option is passed' do
          failure = double 'Failure callback', arity: 2
          failure.should_receive(:call).with(@easy_curl, nil)
          Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, { :on_failure => failure })
          @easy_curl.on_failure.call(@easy_curl)
        end

        it 'should return the http code in the responses' do
          responses = {}
          Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], responses, {})
          @easy_curl.on_failure.call(@easy_curl)

          responses.length.should == 1
          responses[@paul_feed[:url]].should == 500
        end
      end

      describe 'on complete for 404s' do
        before(:each) do
          @headers = "HTTP/1.0 404 Not Found\r\nDate: Thu, 29 Jan 2009 03:55:24 GMT\r\nServer: Apache\r\nX-FB-Host: chi-write6\r\nLast-Modified: Wed, 28 Jan 2009 04:10:32 GMT\r\n"
          @body = 'Page could not be found.'

          @easy_curl.stub(:response_code).and_return(404)
          @easy_curl.stub(:header_str).and_return(@headers)
          @easy_curl.stub(:body_str).and_return(@body)
        end

        it 'should call proc if :on_failure option is passed' do
          complete = double 'Failure callback', arity: 2
          complete.should_receive(:call).with(@easy_curl, 'Server returned a 404')
          Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], {}, { :on_failure => complete })
          @easy_curl.on_missing.call(@easy_curl)
        end

        it 'should return the http code in the responses' do
          responses = {}
          Feedjira::Feed.add_url_to_multi(@multi, @paul_feed[:url], [], responses, {})
          @easy_curl.on_complete.call(@easy_curl)

          responses.length.should == 1
          responses[@paul_feed[:url]].should == 404
        end
      end
    end

    describe "#add_feed_to_multi" do
      before(:each) do
        allow_message_expectations_on_nil
        @multi = Curl::Multi.get([@paul_feed[:url]], {:follow_location => true}, {:pipeline => true})
        @multi.stub(:add)
        @easy_curl = Curl::Easy.new(@paul_feed[:url])
        @feed = Feedjira::Feed.parse(sample_feedburner_atom_feed)

        Curl::Easy.should_receive(:new).and_yield(@easy_curl)
      end

      it "should set user agent if it's passed as an option" do
        Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, :user_agent => 'My cool application')
        @easy_curl.headers["User-Agent"].should == 'My cool application'
      end

      it "should set user agent to default if it's not passed as an option" do
        Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {})
        @easy_curl.headers["User-Agent"].should == Feedjira::Feed::USER_AGENT
      end

      it "should set if modified since as an option if passed" do
        modified_time = Time.parse_safely("Wed, 28 Jan 2009 04:10:32 GMT")
        Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {:if_modified_since => modified_time})
        modified_time.should be > @feed.last_modified

        @easy_curl.headers["If-Modified-Since"].should == modified_time
      end

      it 'should set follow location to true' do
        @easy_curl.should_receive(:follow_location=).with(true)
        Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {})
      end

      it 'should set userpwd for http basic authentication if :http_authentication is passed' do
        Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, :http_authentication => ['myusername', 'mypassword'])
        @easy_curl.userpwd.should == 'myusername:mypassword'
      end

      it "should set if_none_match as an option if passed" do
        @feed.etag = 'ziEyTl4q9GH04BR4jgkImd0GvSE'
        Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {})
        @easy_curl.headers["If-None-Match"].should == 'ziEyTl4q9GH04BR4jgkImd0GvSE'
      end

      describe 'on success' do
        before(:each) do
          @new_feed = @feed.clone
          @feed.stub(:update_from_feed)
          Feedjira::Feed.stub(:decode_content).and_return(@paul_feed[:xml])
          Feedjira::Feed.stub(:determine_feed_parser_for_xml).and_return(Feedjira::Parser::AtomFeedBurner)
          Feedjira::Parser::AtomFeedBurner.stub(:parse).and_return(@new_feed)
          Feedjira::Feed.stub(:etag_from_header).and_return('ziEyTl4q9GH04BR4jgkImd0GvSE')
          Feedjira::Feed.stub(:last_modified_from_header).and_return('Wed, 28 Jan 2009 04:10:32 GMT')
        end

        it 'should parse the updated feed' do
          Feedjira::Parser::AtomFeedBurner.should_receive(:parse).and_return(@new_feed)
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {})
          @easy_curl.on_success.call(@easy_curl)
        end

        it 'should set the last effective url to the feed url' do
          @easy_curl.should_receive(:last_effective_url).and_return(@paul_feed[:url])
          @new_feed.should_receive(:feed_url=).with(@paul_feed[:url])
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {})
          @easy_curl.on_success.call(@easy_curl)
        end

        it 'should set the etags on the feed' do
          @new_feed.should_receive(:etag=).with('ziEyTl4q9GH04BR4jgkImd0GvSE')
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {})
          @easy_curl.on_success.call(@easy_curl)
        end

        it 'should set the last modified on the feed' do
          @new_feed.should_receive(:last_modified=).with('Wed, 28 Jan 2009 04:10:32 GMT')
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {})
          @easy_curl.on_success.call(@easy_curl)
        end

        it 'should add the feed to the responses' do
          responses = {}
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], responses, {})
          @easy_curl.on_success.call(@easy_curl)

          responses.length.should == 1
          responses['http://feeds.feedburner.com/PaulDixExplainsNothing'].should == @feed
        end

        it 'should call proc if :on_success option is passed' do
          success = lambda { |feed| }
          success.should_receive(:call).with(@feed)
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, { :on_success => success })
          @easy_curl.on_success.call(@easy_curl)
        end

        it 'should call update from feed on the old feed with the updated feed' do
          @feed.should_receive(:update_from_feed).with(@new_feed)
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, {})
          @easy_curl.on_success.call(@easy_curl)
        end

        describe 'when the parser invokes its on_failure callback' do
          before(:each) do
            Feedjira::Feed.stub(:determine_feed_parser_for_xml).and_return FailParser
          end

          it 'invokes the on_failure callback' do
            failure = double 'Failure callback', arity: 2
            failure.should_receive(:call)

            Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, { on_failure: failure })
            @easy_curl.on_success.call(@easy_curl)
          end
        end
      end

      describe 'on failure' do
        before(:each) do
          @headers = "HTTP/1.0 404 Not Found\r\nDate: Thu, 29 Jan 2009 03:55:24 GMT\r\nServer: Apache\r\nX-FB-Host: chi-write6\r\nLast-Modified: Wed, 28 Jan 2009 04:10:32 GMT\r\n"
          @body = 'Page could not be found.'

          @easy_curl.stub(:response_code).and_return(404)
          @easy_curl.stub(:header_str).and_return(@headers)
          @easy_curl.stub(:body_str).and_return(@body)
        end

        it 'should call on success callback if the response code is 304' do
          success = lambda { |feed| }
          success.should_receive(:call).with(@feed)
          @easy_curl.should_receive(:response_code).and_return(304)
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], {}, { :on_success => success })
          @easy_curl.on_redirect.call(@easy_curl)
        end

        it 'should return the http code in the responses' do
          responses = {}
          Feedjira::Feed.add_feed_to_multi(@multi, @feed, [], responses, {})
          @easy_curl.on_failure.call(@easy_curl)

          responses.length.should == 1
          responses[@paul_feed[:url]].should == 404
        end
      end
    end

    describe "#fetch_and_parse" do
      it "passes options to multicurl" do
        options = { user_agent: '007' }

        Feedjira::Feed.should_receive(:add_url_to_multi).
          with(anything, anything, anything, anything, options)

        Feedjira::Feed.fetch_and_parse(sample_rss_feed, options)
      end
    end

    describe "#decode_content" do
      before(:each) do
        @curl_easy = double('curl_easy', :body_str => '<xml></xml>')
      end

      it 'should decode the response body using gzip if the Content-Encoding: is gzip' do
        @curl_easy.stub(:header_str).and_return('Content-Encoding: gzip')
        string_io = double('stringio', :read => @curl_easy.body_str, :close => true)
        StringIO.should_receive(:new).and_return(string_io)
        Zlib::GzipReader.should_receive(:new).with(string_io).and_return(string_io)
        Feedjira::Feed.decode_content(@curl_easy)
      end

      it 'should decode the response body using gzip if the Content-Encoding: is gzip even when the case is wrong' do
        @curl_easy.stub(:header_str).and_return('content-encoding: gzip')
        string_io = double('stringio', :read => @curl_easy.body_str, :close => true)
        StringIO.should_receive(:new).and_return(string_io)
        Zlib::GzipReader.should_receive(:new).with(string_io).and_return(string_io)
        Feedjira::Feed.decode_content(@curl_easy)
      end

      it 'should deflate the response body using inflate if the Content-Encoding: is deflate' do
        @curl_easy.stub(:header_str).and_return('Content-Encoding: deflate')
        Zlib::Inflate.should_receive(:inflate).with(@curl_easy.body_str)
        Feedjira::Feed.decode_content(@curl_easy)
      end

      it 'should deflate the response body using inflate if the Content-Encoding: is deflate event if the case is wrong' do
        @curl_easy.stub(:header_str).and_return('content-encoding: deflate')
        Zlib::Inflate.should_receive(:inflate).with(@curl_easy.body_str)
        Feedjira::Feed.decode_content(@curl_easy)
      end

      it 'should return the response body if it is not encoded' do
        @curl_easy.stub(:header_str).and_return('')
        Feedjira::Feed.decode_content(@curl_easy).should == '<xml></xml>'
      end
    end

    describe "#update" do
      it "passes options to multicurl" do
        options = { user_agent: '007' }

        Feedjira::Feed.should_receive(:add_feed_to_multi).
          with(anything, anything, anything, anything, options)

        Feedjira::Feed.update(sample_rss_feed, options)
      end
    end
  end
end
