module CKnife
  class CommandLine

    attr_accessor :option_file, :option_file_contents, :thor_output, :options

    def initialize(f, s, o, opts)
      self.option_file = f
      self.option_file_contents = s
      self.thor_output = o
      self.options = opts
    end

    # dump command?
    def dc(cmd)
      puts "PGPASSFILE=#{pg_pass_file} #{cmd}"
    end

    def write_option_file
      File.open(option_file, "w", 0600) { |f| f.write option_file_contents }
    end

    def delete_opt_file
      if !File.exists?(option_file)
        thor_output.say("No #{option_file} file to delete.")
        return
      end

      s = File.read(option_file)
      if s == option_file_contents
        File.unlink(option_file)
        thor_output.say("Deleted #{option_file} file.")
      else
        thor_output.say("The #{option_file} file's contents do not match what this tool would have generated. Assuming you are trying to delete a #{option_file} file that this tool did not generate, please inspect the file to ensure it contains what you expect, and then delete it yourself.", :red)
      end
    end

    def create_opt_file(connect_msg)
      if File.exists?(option_file)
        thor_output.say("A #{option_file} file is already present.")
        thor_output.say(connect_msg)
        return
      end

      write_option_file
      thor_output.say("Wrote #{option_file} to $CWD.")
      thor_output.say(connect_msg)
      thor_output.say("Remember to delete the #{option_file} file when you are finished.")
    end

    def execute(cmd, input = nil)
      return if !@session_ok
      dc(cmd) if options[:verbose]
      stdin, stdout, stderr, wait_thread = Open3.popen3(cmd)
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

      if result != 0
        @session_ok = false
        msg = "An error occurred."
        msg += " If the --verbose flag is available for this command, you may try turning it on." if !options[:verbose]
        thor_output.say(msg, :red)
      end

      yield if block_given?
      output
    end

    def with_option_file
      if @session_live
        return yield
      end

      @session_live = true
      @session_ok = true

      existing_option_file = false
      if File.exists?(option_file)
        existing_option_file = true
        s = File.read(option_file)
        if s != option_file_contents
          thor_output.say("A #{option_file} file is present, but it does not match your database configuration. The contents of the #{option_file} file must exactly match what this tool would generate. Please reconcile the #{option_file} file with your configuration, and then try again. You can also delete the #{option_file} file since this tool generates one in order to do its job (and removes it after finishing).", :red)
          return
        end
      end

      write_option_file

      result = nil
      begin
        result = yield self # don't know what we're planning to do with the result here...
      ensure
        if !existing_option_file
          FileUtils.rm(option_file)
          if File.exists?(option_file)
            thor_output.say("Failed to remove #{option_file} file. Please remove it for your infrastructure's security.")
          end
        else
          thor_output.say("Left existing #{option_file} file on disk.", :yellow)
        end
      end

      @session_live = false
      result
    end
  end
end

