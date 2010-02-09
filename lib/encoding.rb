require 'uri'

URI::Parser.class_eval do
  def unescape(str, escaped = @regexp[:ESCAPED])
    enc = (str.encoding == Encoding::US_ASCII) ? Encoding::UTF_8 : str.encoding
    str.gsub(escaped) { [$&[1, 2].hex].pack('C') }.force_encoding(enc)
  end
end
