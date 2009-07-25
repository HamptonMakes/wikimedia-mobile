require Merb.root + '/spec/spec_helpers/article_html'

class ARTICLE_GO_MAN_GO_GZIPPED < ARTICLE_GO_MAN_GO
  def self.body_str
    require 'open-uri'
    open(Merb.root + "/spec/fixtures/file.gzip").read
  end
end