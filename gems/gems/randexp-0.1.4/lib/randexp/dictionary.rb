class Randexp::Dictionary
  def self.load_dictionary
    if File.exists?("/usr/share/dict/words")
      File.read("/usr/share/dict/words").split
    elsif File.exists?("/usr/dict/words")
      File.read("/usr/dict/words").split
    else
      raise "words file not found"
    end
  end

  def self.words(options = {})
    case
    when options.has_key?(:length)
      words_by_length[options[:length]]
    else
      @@words ||= load_dictionary
    end
  end

  def self.words_by_length
    @@words_by_length ||= words.inject({}) {|h, w| (h[w.size] ||= []) << w; h }
  end
end