$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'nokogiri'
require 'open-uri'

module Mediawiki
  VERSION = '0.0.2'
  
  def self.search_for_html(wiki_host, term)
    open("http://#{wiki_host}/wiki/Special:Search?search=#{term}")
  end
end