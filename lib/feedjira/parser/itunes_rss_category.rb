# rubocop:disable Style/DocumentationMethod
module Feedjira
  module Parser
    # iTunes extensions to the standard RSS2.0 item
    # Source: https://help.apple.com/itc/podcasts_connect/#/itcb54353390
    class ITunesRSSCategory
      include SAXMachine

      attribute :text

      elements :"itunes:category", as: :itunes_categories,
                                   class: ITunesRSSCategory

      def each_subcategory
        return to_enum(__method__) unless block_given?

        yield text

        itunes_categories.each do |itunes_category|
          itunes_category.each_subcategory(&proc)
        end
      end

      def each_path(ancestors = [])
        return to_enum(__method__, ancestors) unless block_given?

        category_hierarchy = ancestors + [text]

        if itunes_categories.empty?
          yield category_hierarchy
        else
          itunes_categories.each do |itunes_category|
            itunes_category.each_path(category_hierarchy, &proc)
          end
        end
      end
    end
  end
end
