require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedjira::Parser::AtomEntry do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on AtomEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @entry = Feedjira::Parser::Atom.parse(sample_atom_feed).entries.first
  end

  it "should parse the title" do
    expect(@entry.title).to eq "AWS Job: Architect & Designer Position in Turkey"
  end

  it "should parse the url" do
    expect(@entry.url).to eq "http://aws.typepad.com/aws/2009/01/aws-job-architect-designer-position-in-turkey.html"
  end

  it "should parse the url even when" do
    entries = Feedjira::Parser::Atom.parse(load_sample("atom_with_link_tag_for_url_unmarked.xml")).entries
    expect(entries.first.url).to eq "http://www.innoq.com/blog/phaus/2009/07/ja.html"
  end

  it "should parse the author" do
    expect(@entry.author).to eq "AWS Editor"
  end

  it "should parse the content" do
    expect(@entry.content).to eq sample_atom_entry_content
  end

  it "should provide a summary" do
    expect(@entry.summary).to eq "Late last year an entrepreneur from Turkey visited me at Amazon HQ in Seattle. We talked about his plans to use AWS as part of his new social video portal startup. I won't spill any beans before he's ready to..."
  end

  it "should parse the published date" do
    expect(@entry.published).to eq Time.parse_safely("Fri Jan 16 18:21:00 UTC 2009")
  end

  it "should parse the categories" do
    expect(@entry.categories).to eq ['Turkey', 'Seattle']
  end

  it "should parse the updated date" do
    expect(@entry.updated).to eq Time.parse_safely("Fri Jan 16 18:21:00 UTC 2009")
  end

  it "should parse the id" do
    expect(@entry.id).to eq "tag:typepad.com,2003:post-61484736"
  end

  it "should support each" do
    expect(@entry).to respond_to :each
  end

  it "should be able to list out all fields with each" do
    all_fields = []
    title_value = ''

    @entry.each do |field, value|
      all_fields << field
      title_value = value if field == 'title'
    end

    expect(all_fields.sort).to eq ["author", "categories", "content", "entry_id", "links", "published", "summary", "title", "updated", "url"]
    expect(title_value).to eq "AWS Job: Architect & Designer Position in Turkey"
  end

  it "should support checking if a field exists in the entry" do
    expect(@entry).to include 'author'
    expect(@entry).to include 'title'
  end

  it "should allow access to fields with hash syntax" do
    expect(@entry['title']).to eq "AWS Job: Architect & Designer Position in Turkey"
    expect(@entry['author']).to eq "AWS Editor"
  end

  it "should allow setting field values with hash syntax" do
    @entry['title'] = "Foobar"
    expect(@entry.title).to eq "Foobar"
  end
end
