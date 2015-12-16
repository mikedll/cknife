require 'thor'
require 'cknife/config'
require 'daemons'
require 'active_support/all'
require 'cknife/repetition'
require 'rest_client'

module CKnife
  class CKnifeMon < Thor
    attr_accessor :last_error, :last_result, :last_polled_at, :consecutive_error_count, :active

    no_tasks do
      def config
        @config ||= Config
      end

      def conf
        @conf ||= {
          :url => config['mon.url']
        }
      end

      def daemonized_task
        conf # cache file before we lose descriptor

        if @daemonized_task.nil?

          p = proc do
            self.active ||= true
            self.consecutive_error_count ||= 0
            self.last_polled_at = nil

            while true
              sleep 5

              if active && (last_polled_at.nil? || (last_polled_at < Time.now - 10.seconds))
                self.last_error = ""
                self.last_result = nil

                begin
                  result = RestClient.put conf[:url], :params => {} do |response, request, result|
                    if ![200, 201].include?(response.net_http_res.code.to_i)
                      self.last_error = "Unexpected HTTP Result: #{response.net_http_res.code.to_i}"
                    else
                      self.last_result = response.net_http_res.code.to_i
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
          end

          options = {
            :app_name => 'cknife_monitor',
            :mode => :proc,
            :proc => p,
            :ARGV => ["start"],
            :log_output => true,
            :output_logfilename => "cknife_monitor.log",
            :dir_mode => :normal,
            :dir => File.expand_path('.')
          }
          @group ||= Daemons::ApplicationGroup.new(options[:app_name], options)


          @daemonized_task = @group.new_application(options)
        end

        @daemonized_task
      end
    end

    desc "start", "Start monitor."
    def start
      say("Starting.")
      daemonized_task.start
    end

    desc "status", "Show status of monitor."
    def status
      daemonized_task.show_status
    end

    desc "stop", "Stop monitor."
    def stop
      if !daemonized_task.running?
        say("Not running.", :red)
        return
      end

      daemonized_task.stop
      say("Stopped.")
    end
  end
end
