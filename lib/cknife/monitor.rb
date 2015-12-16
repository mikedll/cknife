require 'cknife/backgrounded_polling'

module CKnife
  class Monitor
    attr_accessor :target_endpoint, :last_error, :last_result, :last_polled_at, :consecutive_error_count, :active

    include BackgroundedPolling

    def initialize(url)
      self.target_endpoint = url
      self.active = true
      self.consecutive_error_count = 0
      self.last_polled_at = nil
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
