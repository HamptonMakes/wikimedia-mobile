class Image < Wikipedia::Resource
  def url(width = "200")
    parser = Nokogiri::XML.parse(@server.fetch("/w/api.php?format=xml&action=query&prop=imageinfo&titles=File:#{title}&iiprop=url&iiurlwidth=" + width)[:body])
    parser.css("api query pages page imageinfo ii").first["thumburl"]
  end
end