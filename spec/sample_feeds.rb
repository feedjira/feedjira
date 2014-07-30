module SampleFeeds
  FEEDS = {
    sample_atom_feed: "AmazonWebServicesBlog.xml",
    sample_atom_middleman_feed: "FeedjiraBlog.xml",
    sample_atom_xhtml_feed: "pet_atom.xml",
    sample_atom_feed_line_breaks: "AtomFeedWithSpacesAroundEquals.xml",
    sample_atom_entry_content: "AmazonWebServicesBlogFirstEntryContent.xml",
    sample_itunes_feed: "itunes.xml",
    sample_itunes_feed_with_spaces: "ITunesWithSpacesInAttributes.xml",
    sample_rdf_feed: "HREFConsideredHarmful.xml",
    sample_rdf_entry_content: "HREFConsideredHarmfulFirstEntry.xml",
    sample_rss_feed_burner_feed: "TechCrunch.xml",
    sample_rss_feed_burner_entry_content: "TechCrunchFirstEntry.xml",
    sample_rss_feed_burner_entry_description: "TechCrunchFirstEntryDescription.xml",
    sample_rss_feed: "TenderLovemaking.xml",
    sample_rss_entry_content: "TenderLovemakingFirstEntry.xml",
    sample_feedburner_atom_feed: "PaulDixExplainsNothing.xml",
    sample_feedburner_atom_entry_content: "PaulDixExplainsNothingFirstEntryContent.xml",
    sample_wfw_feed: "PaulDixExplainsNothingWFW.xml",
    sample_google_docs_list_feed: "GoogleDocsList.xml",
    sample_feed_burner_atom_xhtml_feed: "FeedBurnerXHTML.xml",
    sample_duplicate_content_atom_feed: "DuplicateContentAtomFeed.xml"
  }

  FEEDS.each do |method, filename|
    define_method(method) { load_sample filename }
  end

  def load_sample(filename)
    File.read("#{File.dirname(__FILE__)}/sample_feeds/#{filename}")
  end
end
