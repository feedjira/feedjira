require "rubygems"
require "rspec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require "feedzirra"

def load_sample(filename)
  File.read("#{File.dirname(__FILE__)}/sample_feeds/#{filename}")
end

def sample_atom_feed
  load_sample("AmazonWebServicesBlog.xml")
end

def sample_atom_entry_content
  load_sample("AmazonWebServicesBlogFirstEntryContent.xml")
end

def sample_itunes_feed
  load_sample("itunes.xml")
end

def sample_rdf_feed
  load_sample("HREFConsideredHarmful.xml")
end

def sample_rdf_entry_content
  load_sample("HREFConsideredHarmfulFirstEntry.xml")
end

def sample_rss_feed_burner_feed
  load_sample("SamHarrisAuthorPhilosopherEssayistAtheist.xml")
end

def sample_rss_feed
  load_sample("TenderLovemaking.xml")
end

def sample_rss_entry_content
  load_sample("TenderLovemakingFirstEntry.xml")
end

def sample_feedburner_atom_feed
  load_sample("PaulDixExplainsNothing.xml")
end

def sample_feedburner_atom_entry_content
  load_sample("PaulDixExplainsNothingFirstEntryContent.xml")
end

def sample_wfw_feed
  load_sample("PaulDixExplainsNothingWFW.xml")
end       
       
# http://eigenclass.org/hiki/Changes+in+Ruby+1.9#l156
# Default Time.to_s changed in 1.9, monkeypatching it back
class Time
  def to_s
    strftime("%a %b %d %H:%M:%S %Z %Y")
  end
end