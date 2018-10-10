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

    # Leaves out options to simplify output.
    def psql_easy
      "psql #{connection_options} -d #{conf[:database]}"
    end

    def psql_invocation
      "#{psql_easy} --no-align --tuples-only"
    end

    def pg_pass_file
      @pg_pass_file = ".pgpass"
    end

    def dc(cmd)
      puts "PGPASSFILE = #{pg_pass_file} #{cmd}"
    end

    def pg_pass_file_execute(cmd, input = nil)
      return if !@session_ok
      dc(cmd) if options[:verbose]
      stdin, stdout, stderr, wait_thread = Open3.popen3({'PGPASSFILE' => pg_pass_file}, cmd)
      if input
        puts input if options[:verbose]
        stdin.write input
        stdin.close
      end
      output = stdout.read
      output += stderr.read
      $stdout.write output if options[:verbose]
      stdout.close
      stderr.close
      result = wait_thread.value.to_i
      @session_ok = @session_ok && (result == 0)

      # I'm not sure why I allow blocks to this method. 2018-10-09
      yield if block_given?
      output
    end

    def pg_str
      "#{conf[:host]}:#{conf[:port]}:*:#{conf[:username]}:#{conf[:password]}"
    end

    def write_pg_pass_file
      # pgpass format
      File.open(pg_pass_file, "w", 0600) { |f| f.write pg_str }
      pg_pass_file
    end

    def with_pg_pass_file
      if @session_live
        return yield
      end

      @session_live = true
      @session_ok = true

      existing_pgpass = false
      if File.exists?(pg_pass_file)
        existing_pgpass = true
        s = File.read(pg_pass_file)
        if s != pg_str
          say("A .pgpass file is present, but it does not match your database configuration. The contents of the .pgpass file must exactly match what this tool would generate. Please reconcile the .pgpass file with your configuration, and then try again. You can also delete the .pgpass file since this tool generates one in order to do its job (and removes it after finishing).", :red)
          return
        end
      end

      write_pg_pass_file

      result = nil
      begin
        result = yield # don't know what we're planning to do with the result here...
      ensure
        if !existing_pgpass
          FileUtils.rm(pg_pass_file)
          if File.exists?(pg_pass_file)
            say("Failed to remove pg_pass file. Please remove it for security purposes.")
          end
        end
      end

      msg = "Command failed."
      msg += " If the --verbose flag is available for this command, you may try turning it on." if !options[:verbose]
      say
      say(msg, :red) if !@session_ok
      @session_live = false

      result
    end
  end

  desc "disconnect", "Disconnect all sessions from the database. You must have a superuser configured for this to work."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
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
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def capture
    file_name = "db" + Time.now.strftime("%Y%m%d%H%M%S") + ".dump"

    with_pg_pass_file do
      pg_pass_file_execute("pg_dump -Fc --no-owner #{connection_options} -f #{file_name} #{conf[:database]}") do
        say("Captured #{file_name}.")
      end
    end
  end

  desc "sessions", "List active sessions in this database and provide a string suitable for giving to kill for stopping those sessions."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def sessions
    with_pg_pass_file do
      my_pid = pg_pass_file_execute(psql_invocation, "select pg_backend_pid();").split.first
      ids_output = pg_pass_file_execute(psql_invocation, "SELECT procpid, application_name FROM pg_stat_activity WHERE datname = '#{conf[:database]}' AND procpid != #{my_pid};")

      if ids_output.nil?
        say("Error while looking for session information. Possibly a failed login.")
      else
        table = ids_output.split.map { |line| line.split("|") }
        print_table([["PID", "Application Name"]] + table, :indent => 2)
        ids = table.map { |row| row.first }

        say("If you would like to kill these sessions, you can do so with this command:")
        say("kill -9 #{ids.join(' ')}")
      end
    end
  end

  desc "killalls", "Kill all sessions connected to the database."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  method_options :noprompt => false
  def killalls
    if options[:noprompt] || yes?("Are you sure you want to destroy all active sessions connected to the database #{conf[:database]}?", :red)

      with_pg_pass_file do
        pg_pass_file_execute("psql #{connection_options} --no-align --tuples-only CREATE DATABASE #{conf[:database]}") do
          say("Created #{conf[:database]} database.") if @session_ok
        end
      end
    else
      say("No action taken.")
    end

  end

  desc "restore [FILENAME]?", "Restore a file. If no filename is provided, searches for db*.dump files in the $CWD. It will pick the one with the most recent mtime."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def restore(filename=nil)
    to_restore = filename if filename
    if to_restore.nil?
      files = Dir["db*.dump"]
      with_mtime = files.map { |f| [f, File.mtime(f)] }
      with_mtime.sort! { |a,b| a.last <=> b.last }
      files = with_mtime.map(&:first)
      to_restore = files.last
    end

    if to_restore.nil?
      say("No backups file to restore. No file given on the command line, and no files could be found in the $CWD.", :red)
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

  desc "schema [TABLE]?", "Dump the schema for all tables, or one table you specify."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def schema(table=nil)
    table_string = table.nil? ? "" : "--table=#{table.strip}"
    with_pg_pass_file do
      output = pg_pass_file_execute("pg_dump #{connection_options} --no-owner --clean --if-exists --schema-only #{table_string} #{conf[:database]}")

      # This command is so verbose that we only print the output if
      # we didn't already do so in verbose mode.
      puts output if !options[:verbose]
    end
  end

  desc "tables", "List all tables."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def tables(table=nil)
    sql = "SELECT
    table_schema || '.' || table_name
FROM
    information_schema.tables
WHERE
    table_type = 'BASE TABLE'
AND
    table_schema NOT IN ('pg_catalog', 'information_schema');"

    with_pg_pass_file do
      output = pg_pass_file_execute(psql_invocation, sql)
      say ("removing public. prefixes.") if options[:verbose]
      tables = output.split.map do |ts|
        ts =~ /^public\.(.*)$/
        $1
      end
      print_in_columns(tables)
    end
  end

  desc "fexec [FILE]", "Execute a SQL script from a file on disk."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def fexec(file)
    if !File.exists?(file)
      say("'#{file}' does not exist.")
      return
    end

    with_pg_pass_file do
      pg_pass_file_execute("#{psql_invocation} -f #{file}") do
        say("Ran #{file} SQL script.")
      end
    end
  end

  desc "createdb", "Create a database having the name specified in your configuration. Assumes you have privileges to do this."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def createdb
    with_pg_pass_file do
      pg_pass_file_execute("createdb #{connection_options} #{conf[:database]}") do
        say("Created #{conf[:database]} database.") if @session_ok
      end
    end
  end

  desc "dropdb", "Drop the database specified in your configuration."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def dropdb
    with_pg_pass_file do
      pg_pass_file_execute("dropdb #{connection_options} #{conf[:database]};") do
        say("Dropped #{conf[:database]} database.") if @session_ok
      end
    end
  end

  desc "perms", "Create a database having the name specified in your configuration. Assumes you have privileges to do this."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def perms
    with_pg_pass_file do
      pg_pass_file_execute("#{psql_invocation}") do
        puts "hmm."
      end
    end
  end

  desc "passfile", "Write a .pgpass file in $CWD. Useful for starting a psql session on your own."
  def passfile
    connect_msg = "Connect command: PGPASSFILE=.pgpass #{psql_easy}"
    if File.exists?(pg_pass_file)
      say("A .pgpass file is already present.")
      say(connect_msg)
      return
    end

    f = write_pg_pass_file
    say("Wrote #{pg_pass_file} to $CWD.")
    say(connect_msg)
    say("Remember to delete the .pgpass file when you are finished.")
  end

  desc "dpassfile", "Delete the .pgpass file in $CWD, assuming it exactly matches what would be generated by this tool."
  def dpassfile
    if !File.exists?(pg_pass_file)
      say("No .pgpass file to delete.")
      return
    end

    s = File.read(pg_pass_file)
    if s == pg_str
      File.unlink(pg_pass_file)
      say("Deleted .pgpass file.")
    else
      say("The .pgpass file contents do not match what this tool would have generated. Please inspect the file to ensure it contains what you expect, and then delete it yourself.", :red)
    end
  end

  desc "psql", "Launches a psql session. Requires that you prepare a .pgpass file, unless you use --passfile. You can create a .pgpass file with the passfile command."
  method_option :passfile, :type => :boolean, :default => false, :desc => "Write .pgpass file if it doesn't exist."
  method_option :verbose, :default => false, :type => :boolean, :desc => "Show which commands are invoked, any input given to them, and any output they give back."
  def psql
    if !File.exists?(pg_pass_file)
      if !options[:passfile]
        say("You must prepare a .pgpass file for this command, or use --passfile to have this tool craete it for you. You can create a .pgpass file with the passfile command and delete it later with the dpassfile command.")
        return
      end

      write_pg_pass_file
    end

    dc(psql_easy) if options[:verbose]
    exec({'PGPASSFILE' => pg_pass_file}, psql_easy)
  end

end
