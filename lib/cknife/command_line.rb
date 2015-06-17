module CKnife
  class CommandLine

    attr_accessor :option_file, :option_file_contents, :thor_output

    def initialize(f, s, o)
      self.option_file = f
      self.option_file_contents = s
      self.thor_output = o
    end

    def execute(cmd, input = nil)
      return if !@session_ok
      puts cmd
      stdin, stdout, stderr, wait_thread = Open3.popen3(cmd)
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
      yield if @session_ok && block_given?
      output
    end

    def with_option_file
      if @session_live
        return yield
      end

      @session_live = true
      @session_ok = true

      if File.exists?(option_file)
        thor_output.say("This generates a file named #{option_file}, but one is already on disk. Exiting.")
        return
      end

      File.open(option_file, "w", 0600) { |f| f.write option_file_contents }

      result = yield self

      FileUtils.rm(option_file)
      if File.exists?(option_file)
        thor_output.say("Failed to remove #{option_file} file. Please remove it for security purposes.")
      end

      thor_output.say
      thor_output.say("Command failed.", :red) if !@session_ok
      @session_live = false

      result
    end
  end
end

