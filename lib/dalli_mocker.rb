class DalliMocker
  def method_missing(method_name, *args, &block)
    return false
  end
  
  def incr(*args)
    return 1
  end
end