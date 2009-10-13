unless "".respond_to?(:force_encoding)
  class String
    def method_missing(method, *args, &block)
      if method == :force_encoding
        # ignore
        self
      else
        raise NoMethodError
      end
    end
  end
end

