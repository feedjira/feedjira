class String # rubocop:disable Style/Documentation
  def sanitize!
    replace(sanitize)
  end

  def sanitize
    Loofah.scrub_fragment(self, :prune).to_s
  end
end
