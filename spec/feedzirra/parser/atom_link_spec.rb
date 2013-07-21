require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Feedzirra::Parser::AtomLink do
  before(:each) do
    # I don't really like doing it this way because these unit test should only rely on AtomEntry,
    # but this is actually how it should work. You would never just pass entry xml straight to the AtomEnry
    @link = Feedzirra::Parser::Atom.parse(sample_atom_feed).entries.first.link
  end

  it "should get the href" do
    @link.href.should == "http://aws.typepad.com/aws/2009/01/aws-job-architect-designer-position-in-turkey.html"
  end

  it "should get the rel" do
    @link.rel.should == :alternate
  end

  it "should get the type" do
    @link.type.should == "text/html"
  end
end