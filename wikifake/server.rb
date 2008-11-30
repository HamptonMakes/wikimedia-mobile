require 'rubygems'
require 'sinatra'
require 'open-uri'

$articles = {}

get("/*") do
  path = params["splat"].first
  if $articles[path] == nil
    $articles[path] = open("http://en.wikipedia.org/" + path + "?" + request.query_string).read
  end
  $articles[path]
end