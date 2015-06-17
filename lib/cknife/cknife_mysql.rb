require 'open3'
require 'thor'
require 'cknife/config'
require 'cknife/command_line'

module CKnife
  class CKnifeMysql < Thor

    no_tasks do
      def config
        @config ||= Config
      end

      def conf
        @conf ||= {
          :host      => config['mysql.host'] || "localhost",
          :port      => config['mysql.port'] || 3306,
          :database  => config['mysql.database'],
          :username  => config['mysql.username'],
          :password  => config['mysql.password']
        }
      end

      def connection_options
        "--defaults-file=#{option_file} -h #{conf[:host]} -P #{conf[:port]} -u #{conf[:username]}"
      end

      def option_file
        @option_file ||= "my.cnf"
      end

      def command_line
        @command_line ||= CommandLine.new(option_file, "[client]\npassword=\"#{conf[:password]}\"", self)
      end

    end

    desc "capture", "Capture a dump of the database to db(current timestamp).dump."
    def capture
      file_name = "db" + Time.now.strftime("%Y%m%d%H%M%S") + ".sql"

      if File.exists?(file_name)
        say("File already exists: #{file_name}.", :red)
      end

      command_line.with_option_file do |c|
        c.execute "mysqldump #{connection_options} #{conf[:database]} --add-drop-database --result-file=#{file_name}" do
          say("Captured #{file_name}.")
        end
      end
    end

    desc "restore", "Restore a file. Use the one with the most recent mtime by default. Searches for db*.sql files in the CWD."
    method_options :filename => nil
    def restore
      to_restore = options[:filename] if options[:filename]
      if to_restore.nil?
        files = Dir["db*.sql"]
        with_mtime = files.map { |f| [f, File.mtime(f)] }
        with_mtime.sort! { |a,b| a.last <=> b.last }
        files = with_mtime.map(&:first)
        to_restore = files.last
      end

      if to_restore.nil?
        say("No backups file to restore. None given on the command line and none could be found in the CWD.", :red)
        return
      else
        if !yes?("Restore #{to_restore}?", :green)
          return
        end
      end

      command_line.with_option_file do |c|
        say("Doing restore...")

        c.execute("mysql #{connection_options} #{conf[:database]}", "source #{to_restore};") do
          say("Restored #{to_restore}")
        end
      end
    end
  end
end
