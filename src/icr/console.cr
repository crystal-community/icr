module Icr
  class Console
    def initialize
      @command_stack = CommandStack.new
      @last_output = ""
      @crystal_version = get_crystal_version

      @tmp_file_path = Tempfile.new("icr").path
    end

    def start
      command = ask_for_command
      if command =~ /(exit|quit)(\W|\Z)/
        exit 0
      else
        @command_stack.push(command)
      end
      execute
      start
    end

    def execute
      File.write(@tmp_file_path, gen_code)

      io_out = MemoryIO.new
      io_error = MemoryIO.new

      command = "crystal #{@tmp_file_path}"
      status = Process.run(command, nil, nil, false, true, nil, io_out, io_error)

      if status.success?
        output, value = io_out.to_s.split(DELIMITER, 2)

        new_output = output.sub(@last_output, "")
        @last_output = output

        print new_output
        puts " => #{value}"
      else
        # Remove invalid command from the stack
        @command_stack.pop

        # Reformat error message
        lines = io_out.to_s.split("\n")[-6..-1].select { |line| line.strip != "" }
        error_message = lines[0].split(":", 3).last.strip
        code_line = lines[1]
        error_pointer = lines[2]
        puts "  #{error_message}"
        puts "  #{code_line}"
        puts "  #{error_pointer}"
      end
    end

    def gen_code
      @command_stack.to_code
    end

    def ask_for_command
      invitation = "icr(#{@crystal_version}) > "
      Readline.readline(invitation, true).to_s
    end

    def get_crystal_version
      regex = /\d+\.\d+\.\d+/
      output = `crystal --version`
      match = regex.match(output)
      match && match[0]?
    end
  end
end
