require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::GoogleDocsAtomEntry do
  describe 'parsing' do
    before do
      @feed = Feedjira::Parser::GoogleDocsAtom.parse(sample_google_docs_list_feed)
      @entry = @feed.entries.first
    end

    it 'should have the custom checksum element' do
      @entry.checksum.should eql '2b01142f7481c7b056c4b410d28f33cf'
    end

    it 'should have the custom filename element' do
      @entry.original_filename.should eql "MyFile.pdf"
    end

    it 'should have the custom suggested filename element' do
      @entry.suggested_filename.should eql "TaxDocument.pdf"
    end
  end
end
