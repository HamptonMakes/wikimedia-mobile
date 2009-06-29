class Object
  def time_to(thing, &block)
    start_time = Time.now
    result = block.call
    Merb.logger.debug("#{thing} took " + (Time.now - start_time).to_s + " seconds")
    return result
  end
end