Merb.logger.info("Loaded PRODUCTION Environment...")
Merb::Config.use { |c|
  c[:exception_details] = false
  c[:reload_classes] = false
  c[:log_level] = :info
  c[:default_cookie_domain] = ".wikipedia.org"
  
  c[:log_file]  = Merb.root / "log" / "production.log"

  # or redirect logger using IO handle
  #c[:log_stream] = STDOUT
}
