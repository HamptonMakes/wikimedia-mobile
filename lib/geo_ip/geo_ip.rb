#!/usr/bin/ruby
# Original script by 


module GeoIP
  def self.index_file
    File.join(File.dirname(__FILE__), "geo-ip.dat")
  end
  
  def self.lookup(ip_address)
    unless @table
      self.build_index unless File.exists?(index_file)
      # read the binary table upfront
      f = File.open(index_file,"rb")
      @table = f.read
      f.close
    end

    ip_search_in_table(ip_address, @table)
  end

  # Table is an array
  def self.ip_search_in_table(ip_address, table)
    record_max = table.length/10-1
    
    # build a 4-char string representation of IP address
    # in network byte order so it can be a string compare below
    ipstr= ip_address.split(".").map {|x| x.to_i.chr}.join

    # low/high water marks initialized
    low,high=0,record_max
    while true
      mid=(low+high)/2              # binary search median
      # at comparison, values are big endian, i.e. packed("N")
      if ipstr>=table[10*mid,4]     # is this IP not below the current range?
        if ipstr<=table[10*mid+4,4] # is this IP not above the current range?
          return table[10*mid+8,2]    # a perfecct match, voila!
        else
          low=mid+1                 # binary search: raise lower limit
        end
      else
        high=mid-1                  # binary search: reduce upper limit
      end
      if low>high                   # no entries left? nothing found
        return false
      end
    end
  end
  
  def self.build_index
    last_start=nil
    last_end=nil
    last_country=nil
    
    File.open(index_file,"wb") do |ip_table_file|
      IO.foreach("geo-ip.csv") do |line|
        if line.respond_to?("encoding")
          line = line.force_encoding("ISO-8859-1").encode("UTF-8")
        end
      
        next if !(line =~ /^"/ )
          s,e,d1,d2,co=line.delete!("\"").split(",")
          s,e = s.to_i,e.to_i

          if !last_start
            # initialize with first entry
            last_start,last_end,last_country = s,e,co
          else
            if s==last_end+1 and co==last_country
              # squeeze if successive ranges have zero gap
              last_end=e
            else
              # append last entry, remember new one
              ip_table_file << [last_start,last_end,last_country].pack("NNa2")
              last_start,last_end,last_country = s,e,co
            end
          end
      end

      # print last entry
      if last_start
        ip_table_file << [last_start,last_end,last_country].pack("NNa2")
      end
    end
  end
end