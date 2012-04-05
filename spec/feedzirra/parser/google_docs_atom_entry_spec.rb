require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::GoogleDocsAtomEntry do
  describe 'parsing' do
    before do
      @feed = Feedzirra::Parser::GoogleDocsAtom.parse(sample_google_docs_list_feed)
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

    it 'should yank out content as a download_url' do
      @entry.download_url.should_not be_empty
    end

    it 'should yank out content as a mime_type' do
      @entry.mime_type.should_not be_empty
    end

    it 'should yank out a parent collection name' do
      @entry.parent_collection_title.should == 'ACollectionName'
    end

    it 'should yank out a parent collection URL' do
      @entry.parent_collection_url.should == 'https://docs.google.com/feeds/default/private/full/folder%3A12345'
    end
  end
end
