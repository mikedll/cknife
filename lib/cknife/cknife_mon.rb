require 'thor'
require 'daemons'
require 'active_support/all'
require 'rest_client'

require 'cknife/config'
require 'cknife/monitor'
require 'cknife/repetition'

module CKnife
  class CKnifeMon < Thor

    no_tasks do
      def config
        @config ||= Config
      end

      def conf
        @conf ||= {
          :url => config['mon.url']
        }
      end

      def monitor
        @monitor ||= CKnife::Monitor.new(conf[:url])
      end

      def daemonized_task
        conf # cache file before we lose descriptor

        if @daemonized_task.nil?

          p = proc do
            while true
              sleep 5
              monitor.poll_background
            end
          end

          options = {
            :app_name => 'cknife_monitor',
            :mode => :proc,
            :proc => p,
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

    desc "restart", "Restart monitor."
    def restart
      stop
      start
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
