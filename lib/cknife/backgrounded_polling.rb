require 'active_support/concern'

# mixin client must define:
#
#   before_poll
#   handle_poll_result(response, request, result)
#   target_endpoint
#
# And these fields:
#
#  last_error
#  last_polled_at
#  active
#  consecutive_error_count
#
# And implement a loop that calls poll_background.
# This is optional:
#
#  payload
#
module CKnife
  module BackgroundedPolling
    extend ActiveSupport::Concern

    class IneligibleToPoll < StandardError
    end

    BACKGROUND_POLL = 'background_poll'

    included do
      def payload
        {}
      end

      def poll_background
        if active && (last_polled_at.nil? || (last_polled_at < Time.now - 15.minutes))
          before_poll
          self.last_error = ""

          begin
            result = RestClient.put(target_endpoint, payload) do |response, request, result|
              if ![200, 201].include?(response.net_http_res.code.to_i)
                self.last_error = "Unexpected HTTP Result: #{response.net_http_res.code.to_i}"
              else
                handle_poll_result(response, request, result)
              end
            end
          rescue => e
            self.last_error = e.message
          end

          if !last_error.blank?
            self.consecutive_error_count += 1
            self.active = false if consecutive_error_count >= Repetition::MAX_CONSECUTIVE
            puts "Failed to ping home url. Last error: #{last_error}."
          else
            self.consecutive_error_count = 0
            puts "Pinged home url with result #{last_result}."
          end

          self.last_polled_at = Time.now
        end
      end

      def reset_last_poll
        self.last_polled_at = Time.now
      end
    end

  end
end
