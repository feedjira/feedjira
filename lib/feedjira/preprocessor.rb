# rubocop:disable Style/Documentation
# rubocop:disable Style/DocumentationMethod
module Feedjira
  class Preprocessor
    def initialize(xml)
      @xml = xml
    end

    def to_xml
      process_content
      doc.to_xml
    end

    private

    def process_content
      content_nodes.each do |node|
        node.content = raw_html(node) unless node.cdata?
      end
    end

    def content_nodes
      doc.search 'entry > content[type="xhtml"], entry > summary[type="xhtml"], entry > title[type="xhtml"]' # rubocop:disable Metrics/LineLength
    end

    def raw_html(node)
      node.search('./div').inner_html
    end

    def doc
      @doc ||= Nokogiri::XML(@xml).remove_namespaces!
    end
  end
end
