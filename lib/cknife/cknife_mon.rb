require 'thor'
require 'cknife/config'

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
    end

    desc "start", "Start daemon."
    def start
      say("Starting.")
    end

    desc "stop", "Stop daemon"
    def stop
      say("Stopped.")
    end
  end
end
