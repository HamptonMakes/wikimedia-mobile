require 'rubygems'
#require "../vendor/gems/ruby/1.9.1/environment"

#begin
  require 'activesupport'
#rescue LoadError
#  require 'active_support'
#end

require 'dm-core'
require "dm-aggregates"


$first_day = Date.parse("2009-06-20")

DataMapper.setup(:default, "mysql://root@localhost/stats")

require 'models/stat'

class Array
  def mean
    return 0.0 if self.size == 0
    sum / self.size.to_f
  end

  def sum
    total = 0
    self.each do |val|
      if val.is_a? Numeric
        total += val
      end
    end
    total
  end
end