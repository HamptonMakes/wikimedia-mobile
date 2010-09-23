module Merb::Rack

  class UDPLogger
    def initialize(app)
      @app = app
      @sock = UDPSocket.open
      @hostname = `hostname --fqdn`.chomp
    end

    def deferred?(env)
      @app.deferred?(env) if @app.respond_to?(:deferred?)
    end

    def call(env)
      request_count = Cache.incr("request_count", 1, 60 * 60 * 24, 1)
      start = Time.now
      status, headers, body = @app.call(env)
      took = (Time.now - start).to_s
      req = Rack::Request.new(env)
      content_type = headers['Content-Type'] ? headers['Content-Type'].split(";").first : '-'
      timestamp = start.getutc.iso8601(2)[0..-2]
      datagram = "#{@hostname} #{request_count} #{timestamp} #{took} #{req.ip} TCP_MISS/#{status} #{body.size + headers.size} #{req.request_method.upcase} #{req.url} NONE/- #{content_type} #{env['HTTP_REFERRER'] || '-'} #{env['X-Forwarded-For'] || '-'} #{URI::encode(env['HTTP_USER_AGENT'] || '')}"

      puts datagram

      @sock.send(datagram, 0, "208.80.152.138", 8420)

      [status, headers, body]
    end
  end
end
