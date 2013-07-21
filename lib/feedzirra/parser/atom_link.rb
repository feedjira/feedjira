module Feedzirra

  module Parser
    # Parser for dealing with Atom link entries.
    class AtomLink
      include SAXMachine

      attribute :href, :as => :parsed_href
      attribute :rel,  :as => :parsed_rel
      attribute :type

      def ==(val)
        val == href
      end

      # RFC4287 4.2.7.2: If the "rel" attribute is not present, the link
      # element MUST be interpreted as if the link relation type is
      # "alternate"
      def rel
        return @rel unless @rel.nil?
        return parsed_rel.to_sym unless parsed_rel.nil?
        return :alternate
      end

      def rel=(r)
        @rel = r.to_sym
      end

      def href=(h)
        @href = h
      end

      def href
        return @href unless @href.nil?
        return parsed_href
      end

      def inspect
        string = "#<#{self.class.name}:#{self.object_id} "
        string << "rel: #{rel}, href: #{href}, type: #{type}>"
      end
    end
  end
end
