module Feedzirra
  class AtomFeedBurner
    def self.will_parse?(xml)
      (xml =~ /Atom/ && xml =~ /feedburner/) || false
    end
  end
end