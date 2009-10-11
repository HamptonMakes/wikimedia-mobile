unless "".respond_to?(:force_encoding)
  class String
    def force_encoding(encoding)
      # ignore
      self
    end
  end
end