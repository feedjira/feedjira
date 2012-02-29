require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::GoogleDocsAtom do
  describe '.able_to_parser?' do
    it 'should return true for Google Docs feed' do
      Feedzirra::Parser::GoogleDocsAtom.should be_able_to_parse(sample_google_docs_list_feed)
    end

    it 'should not be able to parse another Atom feed' do
      Feedzirra::Parser::GoogleDocsAtom.should_not be_able_to_parse(sample_atom_feed)
    end
  end

  describe 'parsing' do
    before do
      @feed = Feedzirra::Parser::GoogleDocsAtom.parse(sample_google_docs_list_feed)
    end

    it 'should return a bunch of objects' do
      @feed.entries.should_not be_empty
    end

    it 'should populate a title, interhited from the Atom entry' do
      @feed.title.should_not be_nil
    end

    it 'should return a bunch of entries of type GoogleDocsAtomEntry' do
      @feed.entries.first.should be_a Feedzirra::Parser::GoogleDocsAtomEntry
    end
  end
end
