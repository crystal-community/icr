module Icr
  # Build crystal source code file based on commands in CommandStack, executes it
  # as crystal program and returns result as an instance of ExecutionResult.
  class Executer
    def initialize(@command_stack : CommandStack, @debug = false)
      # Temporary file where generated source code is written
      # NOTE: File is created in the current dir, in order to be able to
      # require local files.
      @tmp_file_name = ".icr_#{SecureRandom.urlsafe_base64}.cr"
      @tmp_file_path = File.join(Dir.current, @tmp_file_name)

      # Accumulates the output from previous executions, so we can distinguish the
      # new output from the previous.
      @previous_output = ""
    end

    def execute
      File.write(@tmp_file_path, @command_stack.to_code)
      io_out = IO::Memory.new
      io_error = IO::Memory.new
      command = "#{CRYSTAL_COMMAND} #{@tmp_file_path} --no-debug"
      status = Process.run(command, nil, nil, false, true, nil, io_out, io_error)
      print_source_file if @debug

      File.delete(@tmp_file_path)

      if status.success?
        output, value = io_out.to_s.split(DELIMITER, 2)
        new_output = output.sub(@previous_output, "")
        @previous_output = output
        ExecutionResult.new(true, value, new_output, nil)
      else
        # Remove invalid command from the stack
        @command_stack.pop
        error_message =
          # Get the last message in the backktrace (in order not to show tmp file internals)
          io_out.to_s.split(/#{@tmp_file_name}:\d+: /).last.strip +
          "\n" +
          io_error.to_s.strip
        ExecutionResult.new(false, nil, nil, error_message.strip)
      end
    end

    def print_source_file
      puts
      puts "========================= ICR FILE BEGIN =========================="
      puts File.read(@tmp_file_path)
      puts "========================== ICR FILE END ============================"
      puts
    end

    # Remove .crystal directory and internals created by +crystal+ command.
    def cleanup!
      dot_crystal_dir = File.join(Dir.current, ".crystal")
      file_tmp_dir = File.join(dot_crystal_dir, @tmp_file_path)

      # Remove tmp directory of the tmp file
      system("rm -rf \"#{file_tmp_dir}\"")

      path = File.expand_path("..", file_tmp_dir)

      # Remove empty directories, including ".crystal"
      while empty_dir?(path)
        Dir.rmdir(path)
        break if path == dot_crystal_dir
        path = File.expand_path("..", path)
      end
    end

    private def empty_dir?(path)
      return false unless File.directory?(path)
      entries = Dir.entries(path) - [".", ".."]
      entries.empty?
    end
  end
end
