require 'spec_helper'

describe Feedjira::Preprocessor do
  it 'returns the xml as parsed by Nokogiri' do
    xml = '<xml></xml>'
    doc = Nokogiri::XML(xml).remove_namespaces!
    processor = Feedjira::Preprocessor.new xml
    escaped = processor.to_xml

    expect(escaped).to eq doc.to_xml
  end

  it 'escapes markup in xhtml content' do
    processor = Feedjira::Preprocessor.new sample_atom_xhtml_feed
    escaped = processor.to_xml

    expect(escaped.split("\n")[10]).to match /&lt;i&gt;dogs&lt;\/i&gt;/ #title
    expect(escaped.split("\n")[16]).to match /&lt;b&gt;XHTML&lt;\/b&gt;/ #summary
    expect(escaped.split("\n")[26]).to match /&lt;p&gt;$/ #content
  end

  it 'leaves escaped html within pre tag' do
    processor = Feedjira::Preprocessor.new sample_atom_xhtml_with_escpaed_html_in_pre_tag_feed
    escaped = processor.to_xml
    expect(escaped.split("\n")[7]).to eq "        &lt;pre&gt;&amp;lt;b&amp;gt;test&amp;lt;b&amp;gt;&lt;/pre&gt;"
  end
end
