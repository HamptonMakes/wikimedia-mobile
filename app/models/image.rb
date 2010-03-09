class Image < Wikipedia::Resource
  def url(width = "200")
    Nokogiri::XML.parse(@server.fetch("/w/api.php?action=query&prop=imageinfo&titles=File:Seretide250.jpg&iiprop=url&iiurlwidth=199"))
  end
end