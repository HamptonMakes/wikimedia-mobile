require 'stringio' 
require 'zlib'

class String
  def unzip
    begin 
      gz = Zlib::GzipReader.new( StringIO.new( self ) )
      return gz.read
    rescue Zlib::GzipFile::Error
      # If its not looking gzipped, just display it
      return self
    end
  end
  
  def zip
    #begin
      stringio = StringIO.new()
      
      gz = Zlib::GzipWriter.new(stringio)
      gz.write self
      gz.close
      
      return stringio.string
    #rescue Zlib::GzipFile::Error
    #  # If its not looking gzipped, just display it
    #  return self
    #end
  end
end

