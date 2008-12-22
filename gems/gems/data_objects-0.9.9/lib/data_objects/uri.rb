gem 'addressable', '~>2.0'
require 'addressable/uri'

module DataObjects
  URI = Struct.new(:scheme, :user, :password, :host, :port, :path, :query, :fragment)

  class URI
    def self.parse(uri)
      return uri if uri.kind_of?(self)
      uri = Addressable::URI::parse(uri) unless uri.kind_of?(Addressable::URI)
      self.new(uri.scheme, uri.user, uri.password, uri.host, uri.port, uri.path, uri.query, uri.fragment)
    end

    def to_s
      string = ""
      string << "#{scheme}://"   if scheme
      if user
        string << "#{user}"
        string << ":#{password}" if password
        string << "@"
      end
      string << "#{host}"        if host
      string << ":#{port}"       if port
      string << path.to_s
      string << "?#{query}"      if query
      string << "##{fragment}"   if fragment
      string
    end
  end
end