class Object
  def time_to(thing, &block)
    start_time = Time.now
    result = block.call
    Merb.logger[:time_to] ||= {}
    Merb.logger[:time_to][thing] = (Time.now - start_time)
    return result
  end
end