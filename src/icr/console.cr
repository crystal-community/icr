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
      if command.nil?
        # Ctrl+D was pressed, print new line before exit
        puts
        exit 0
      elsif command.to_s =~ /(exit|quit)(\W|\Z)/
        exit 0
      elsif command.to_s.strip != ""
        # if command is not empty, try to execute
        @command_stack.push(command.to_s)
        execute
      end
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

        # Print the last message in the backktrace
        puts io_out.to_s.split(/#{@tmp_file_path}:\d+: /).last
      end
    end

    def gen_code
      @command_stack.to_code
    end

    def ask_for_command
      invitation = "icr(#{@crystal_version}) > "
      Readline.readline(invitation, true)
    end

    def get_crystal_version
      regex = /\d+\.\d+\.\d+/
      output = `crystal --version`
      match = regex.match(output)
      match && match[0]?
    end
  end
end
