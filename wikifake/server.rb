require 'rubygems'
require 'sinatra'
require 'open-uri'

$articles = {}

get("/*") do
  path = params["splat"].first + "?" + request.query_string
  if $articles[path] == nil
    $articles[path] = open("http://en.wikipedia.org/" + path).read
  end
  $articles[path]
end