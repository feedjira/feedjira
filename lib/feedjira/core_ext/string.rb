# rubocop:disable Style/DocumentationMethod Style/Documentation
class String
  def sanitize!
    replace(sanitize)
  end

  def sanitize
    Loofah.scrub_fragment(self, :prune).to_s
  end
end
