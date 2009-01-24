module Feedzirra
  class RSS
    def self.will_parse?(xml)
      xml =~ /rss version\=\"2\.0\"/ || false
    end
  end
end