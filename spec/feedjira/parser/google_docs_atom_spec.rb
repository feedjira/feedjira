require 'spec_helper'

module Feedjira::Parser
  describe '.able_to_parser?' do
    it 'should return true for Google Docs feed' do
      expect(GoogleDocsAtom).to be_able_to_parse(sample_google_docs_list_feed)
    end

    it 'should not be able to parse another Atom feed' do
      expect(GoogleDocsAtom).to_not be_able_to_parse(sample_atom_feed)
    end
  end

  describe 'parsing' do
    before do
      @feed = GoogleDocsAtom.parse(sample_google_docs_list_feed)
    end

    it 'should return a bunch of objects' do
      expect(@feed.entries).to_not be_empty
    end

    it 'should populate a title, interhited from the Atom entry' do
      expect(@feed.title).to_not be_nil
    end

    it 'should return a bunch of entries of type GoogleDocsAtomEntry' do
      expect(@feed.entries.first).to be_a GoogleDocsAtomEntry
    end
  end
end
