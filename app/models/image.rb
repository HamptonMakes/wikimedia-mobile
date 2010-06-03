class Image < Wikipedia::Resource
  def url(width = "310")
    parser = Nokogiri::XML.parse(@server.fetch("/w/api.php?format=xml&action=query&prop=imageinfo&titles=File:#{title}&iiprop=url&iiurlwidth=#{width}")[:body])
    item = parser.css("api query pages page imageinfo ii").first
    if !item.nil?
      return item["thumburl"]
    else
      ""
    end
  end
  
  def original_url
    parser = Nokogiri::XML.parse(@server.fetch("/w/api.php?format=xml&action=query&titles=File:#{title}&prop=imageinfo&iiprop=url")[:body])
    parser.css("api query pages page imageinfo ii").first["url"]
  end
  
  def name
    title.gsub("_", " ").split(".")[0..-2].join(".")
  end
  
  def wiki_name
    "File:" + title
  end
end