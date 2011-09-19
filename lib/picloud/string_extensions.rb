class String
  def nil_or_whitespace?
    return self.nil? || self.strip.empty?
  end
end
