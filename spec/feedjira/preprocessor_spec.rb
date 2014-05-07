require 'spec_helper'

describe Feedjira::Preprocessor do
  it 'returns the xml as parsed by Nokogiri' do
    xml = '<xml></xml>'
    doc = Nokogiri::XML(xml).remove_namespaces!
    processor = Feedjira::Preprocessor.new xml
    escaped = processor.to_xml

    escaped.should eq doc.to_xml
  end

  it 'escapes markup in xhtml content' do
    processor = Feedjira::Preprocessor.new sample_atom_xhtml_feed
    escaped = processor.to_xml

    escaped.split("\n")[26].should match /&lt;p&gt;$/
  end
end
