require 'cknife/backgrounded_polling'

module CKnife
  class Monitor
    attr_accessor :url, :api_key, :last_error, :last_result, :last_polled_at, :consecutive_error_count, :active

    include BackgroundedPolling

    def initialize(url, options = {})
      self.url = url
      self.active = true
      self.consecutive_error_count = 0
      self.last_polled_at = nil
      self.api_key = options[:api_key] if options[:api_key]
    end

    def target_endpoint
      u = URI.parse(url)
      u.userinfo = "#{api_key}:#{api_key}" if api_key
      u.to_s
    end

    def before_poll
      self.last_result = nil
    end

    def handle_poll_result(response, request, result)
      self.last_result = response.net_http_res.code.to_i
    end

    def payload
      res = `cat /proc/meminfo`
      lines = res.split("\n")
      matcher = /:\s+(\d+)/
      lines[0] =~ matcher
      total = $1
      lines[1] =~ matcher
      free = $1
      stats = { :free => free.to_i, :total => total.to_i }
    end
  end
end
