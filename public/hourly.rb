class Hourly < Scout::Plugin
  def build_report
    `/srv/wikimedia-mobile/bin/hourly > /srv/wikimedia-mobile/log/hourly.log`
  end
end