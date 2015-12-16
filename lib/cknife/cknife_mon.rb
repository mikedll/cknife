require 'thor'
require 'cknife/config'
require 'daemons'

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

      def daemonized_task
        if @daemonized_task.nil?

          p = proc do
            while true
              sleep 4
              puts "*************** #{__FILE__} #{__LINE__} *************"
              puts "pinging."
            end
          end

          options = {
            :app_name => 'cknife_monitor',
            :mode => :proc,
            :proc => p,
            :ARGV => ["start"],
            :logfilename => "output.log",
            :output_logfilename => "output.log"
          }
          @group ||= Daemons::ApplicationGroup.new(options[:app_name], options)


          @daemonized_task = @group.new_application(options)
        end

        @daemonized_task
      end
    end

    desc "start", "Start daemon."
    def start
      say("Starting.")
      daemonized_task.start
    end

    desc "stop", "Stop daemon"
    def stop
      say("Stopped.")
      daemonized_task.stop
    end
  end
end
