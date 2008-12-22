class Symbol
  
  def try_dup
    self
  end
  
  ##
  # @param o<String, Symbol> The path component to join with the string.
  #
  # @return <String> The original path concatenated with o.
  #
  # @example
  #   :merb/"core_ext" #=> "merb/core_ext"
  def /(o)
    File.join(self.to_s, o.to_s)
  end
end