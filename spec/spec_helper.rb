begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
end

require File.expand_path(File.dirname(__FILE__) + '/../lib/feedzirra')

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
  load_sample("TechCrunch.xml")
end

def sample_rss_feed_burner_entry_content
  load_sample("TechCrunchFirstEntry.xml")
end

def sample_rss_feed_burner_entry_description
  load_sample("TechCrunchFirstEntryDescription.xml")
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

def sample_google_docs_list_feed
  load_sample("GoogleDocsList.xml")
end       

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end