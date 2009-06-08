require 'rubygems'
require 'dm-core'

DataMapper.setup(:default, "mysql://root@localhost/stats")

require 'models/stat_segment'