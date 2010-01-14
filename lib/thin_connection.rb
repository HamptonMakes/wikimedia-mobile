class Thin::Connection
   # Called when data is received from the client.
  def receive_data(data)
    trace { data }
    process if @request.parse(data)
  rescue Exception
    log "!! Invalid request handled"
    #log_error e
    post_process [500, {}, '']
  end
end