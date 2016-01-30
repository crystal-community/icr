module Icr
  # Build crystal source code file based on commands in CommandStack, executes it
  # as crystal program and returns result as an instance of ExecutionResult.
  class Executer
    def initialize(@command_stack)
      # Temporary file where generated source code is written
      @tmp_file_path = Tempfile.new("icr").path

      # Accumulates the output from previous executions, so we can distinguish the
      # new output from the previous.
      @previous_output = ""
    end

    def execute
      File.write(@tmp_file_path, @command_stack.to_code)
      io_out = MemoryIO.new
      io_error = MemoryIO.new
      command = "#{CRYSTAL_COMMAND} #{@tmp_file_path}"
      status = Process.run(command, nil, nil, false, true, nil, io_out, io_error)

      if status.success?
        output, value = io_out.to_s.split(DELIMITER, 2)
        new_output = output.sub(@previous_output, "")
        @previous_output = output
        ExecutionResult.new(true, value, new_output, nil)
      else
        # Remove invalid command from the stack
        @command_stack.pop
        # Get the last message in the backktrace (Crystal writes error message to STDOUT)
        error_message = io_out.to_s.split(/#{@tmp_file_path}:\d+: /).last
        ExecutionResult.new(false, nil, nil, error_message)
      end
    end
  end
end
