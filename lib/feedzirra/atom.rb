module Feedzirra
  class Atom
    def self.will_parse?(xml)
      xml =~ /Atom/ || false
    end
  end
end