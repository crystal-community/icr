module Icr
  class Console
    def initialize
      @command_stack = CommandStack.new
      @last_output = ""
      @crystal_version = get_crystal_version
    end

    def start
      command = ask_for_command
      if command.strip == "exit"
        exit 0
      else
        @command_stack.push(command)
      end
      execute
      start
    end

    def execute
      file_path = "/tmp/icr.cr"
      File.write(file_path, gen_code)


      io_out = MemoryIO.new
      io_error = MemoryIO.new

      command = "crystal #{file_path}"
      status = Process.run(command, nil, nil, false, true, nil, io_out, io_error)

      if status.success?
        output, value = io_out.to_s.split(DELIMITER, 2)

        new_output = output.sub(@last_output, "")
        @last_output = output

        print new_output
        puts " => #{value}"
      else
        # TODO: do something
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
