require 'open3'
require 'thor'
require 'cknife/config'

class CKnifePg < Thor

  no_tasks do
    def config
      @config ||= CKnife::Config
    end

    def conf
      @conf ||= {
        :host      => config['pg.host'] || "localhost",
        :port      => config['pg.port'] || 5432,
        :database  => config['pg.database'],
        :username  => config['pg.username'],
        :password  => config['pg.password']
      }
    end

    def connection_options
      "-h #{conf[:host]} -p #{conf[:port]} -U #{conf[:username]} --no-password"
    end

    def psql_invocation
      "psql #{connection_options} -d #{conf[:database]} --no-align --tuples-only"
    end

    def pg_pass_file
      @pg_pass_file = ".pgpass"
    end

    def pg_pass_file_execute(cmd, input = nil)
      return if !@session_ok
      puts cmd
      stdin, stdout, stderr, wait_thread = Open3.popen3({'PGPASSFILE' => pg_pass_file}, cmd)
      if input
        puts input
        stdin.write input
        stdin.close
      end
      output = stdout.read
      output += stderr.read
      $stdout.write output
      stdout.close
      stderr.close
      result = wait_thread.value.to_i
      @session_ok = @session_ok && (result == 0)
      yield if block_given?
      output
    end

    def with_pg_pass_file
      if @session_live
        return yield
      end

      @session_live = true
      @session_ok = true

      if File.exists?(pg_pass_file)
        say("This generates a pgpass file but one is already on disk. Exiting.")
        return
      end

      # pgpass format
      File.open(pg_pass_file, "w", 0600) { |f| f.write "#{conf[:host]}:#{conf[:port]}:*:#{conf[:username]}:#{conf[:password]}" }

      result = yield

      FileUtils.rm(pg_pass_file)
      if File.exists?(pg_pass_file)
        say("Failed to remove pg_pass file. Please remove it for security purposes.")
      end

      say
      say("Command failed.", :red) if !@session_ok
      @session_live = false

      result
    end
  end

  desc "disconnect", "Disconnect all sessions from the database. You must have a superuser configured for this to work."
  def disconnect
    with_pg_pass_file do
      my_pid = pg_pass_file_execute(psql_invocation, "select pg_backend_pid();").split.first
      ids = pg_pass_file_execute(psql_invocation, "SELECT procpid FROM pg_stat_activity WHERE datname = '#{conf[:database]}' AND procpid != #{my_pid};")
      ids.split.each do |pid|
        pg_pass_file_execute(psql_invocation, "select pg_terminate_backend(#{pid});")
      end
    end
  end

  desc "capture", "Capture a dump of the database to db(current timestamp).dump."
  def capture
    file_name = "db" + Time.now.strftime("%Y%m%d%H%M%S") + ".dump"

    with_pg_pass_file do
      pg_pass_file_execute("pg_dump -Fc --no-owner #{connection_options} -f #{file_name} #{conf[:database]}") do
        say("Captured #{file_name}.")
      end
    end
  end

  desc "sessions", "List active sessions in this database and provide a string suitable for giving to kill for stopping those sessions."
  def sessions
    with_pg_pass_file do
      my_pid = pg_pass_file_execute(psql_invocation, "select pg_backend_pid();").split.first
      ids_output = pg_pass_file_execute(psql_invocation, "SELECT procpid, application_name FROM pg_stat_activity WHERE datname = '#{conf[:database]}' AND procpid != #{my_pid};")
      table = ids_output.split.map { |line| line.split("|") }
      print_table([["PID", "Application Name"]] + table, :indent => 2)
      ids = table.map { |row| row.first }

      say("If you would like to kill these sessions, you can do so with this command:")
      say("kill -9 #{ids.join(' ')}")
    end
  end

  desc "restore", "Restore a file. Use the one with the most recent mtime by default. Searches for db*.dump files in the CWD."
  method_options :filename => nil
  def restore
    to_restore = options[:filename] if options[:filename]
    if to_restore.nil?
      files = Dir["db*.dump"]
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

    with_pg_pass_file do
      output = pg_pass_file_execute("dropdb #{connection_options} #{conf[:database]}")

      if !@session_ok
        if output.split("\n").any? { |s| s =~ /There are [0-9]+ other session\(s\) using the database./ }
          say
          say("Other sessions are blocking the database from being dropped.")
          say("You may want to terminate these sessions and try again. See the 'sessions' command.")
        end
      else
        say("Doing restore...")

        pg_pass_file_execute("createdb -T template0 #{connection_options} #{conf[:database]}")
        pg_pass_file_execute("pg_restore -n public --no-privileges --no-owner #{connection_options} -d #{conf[:database]} #{to_restore}") do
          say("Restored #{to_restore}")
        end
      end
    end
  end
end