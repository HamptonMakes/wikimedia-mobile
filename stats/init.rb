require 'rubygems'
require 'dm-core'
require 'dm-aggregates'

DataMapper.setup(:default, "mysql://root@localhost/stats")

require 'models/stat_segment'