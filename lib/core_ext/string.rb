class String
  def sanitize!
    self.replace(sanitize)
  end
  
  def sanitize
    Dryopteris.sanitize(self)
  end
end