require "rubygems"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require "lib/feedzirra"

def sample_atom_feed
  File.read("#{File.dirname(__FILE__)}/sample_feeds/AmazonWebServicesBlog.xml")
end

def sample_rdf_feed
  File.read("#{File.dirname(__FILE__)}/sample_feeds/ArunGuptasBlog.xml")
end

def sample_feedburner_feed
  File.read("#{File.dirname(__FILE__)}/sample_feeds/PaulDixExplainsNothing.xml")
end