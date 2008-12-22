require 'rubygems'
require 'pathname'

gem 'dm-core', '~>0.9.7'
require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-types'

require dir / 'csv'
require dir / 'enum'
require dir / 'epoch_time'
require dir / 'file_path'
require dir / 'flag'
require dir / 'ip_address'
require dir / "json"""
require dir / 'uri'
require dir / 'uuid'
require dir / 'yaml'
require dir / 'serial'
require dir / 'regexp'
require dir / 'slug'

# this looks a little ugly, but everyone who uses dm-types shouldn't have to have ruby-bcrypt installed
module DataMapper
  module Types
    autoload(:BCryptHash, File.join(Pathname(__FILE__).dirname.expand_path, 'dm-types', 'bcrypt_hash'))
  end
end
