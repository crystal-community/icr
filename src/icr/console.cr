module Icr
  # Responsible for interaction with user.
  class Console
    def initialize
      @command_stack = CommandStack.new
      @executer = Executer.new(@command_stack)
      @crystal_version = get_crystal_version!
    end

    def start
      loop do
        input = ask_for_input
        process_input(input)
      end
    end

    private def process_input(input)
      if input.nil?
        # Ctrl+D was pressed, print new line before exit
        puts
        exit 0
      elsif input.to_s =~ /(exit|quit)(\W|\Z)/
        exit 0
      elsif input.to_s.strip != ""
        execute_command(input.to_s)
      end
    end

    private def execute_command(command : String)
      Crystal::Parser.parse(command)
      @command_stack.push(command)
      execute
    rescue err : Crystal::SyntaxException
      if err.message =~ /EOF/
        continue_command(command)
      else
        puts err.message
      end
    end

    private def continue_command(command)
      p2 = ask_for_input(1)
      new_cmd = "#{command}\n#{p2}"
      Crystal::Parser.parse(new_cmd)
      @command_stack.push(new_cmd)
      execute
    rescue err : Crystal::SyntaxException
      if err.message =~ /EOF/
        continue_command(new_cmd)
      else
        puts err.message
      end
    end

    private def execute
      result = @executer.execute
      if result.success?
        print result.output
        puts " => #{result.value}"
      else
        puts result.error_output
      end
    end

    private def ask_for_input(level = 0)
      invitation = default_invitation + "  " * level
      Readline.readline(invitation, true)
    end

    private def get_crystal_version!
      if `which #{CRYSTAL_COMMAND}`.strip  == ""
        abort("Can not find `#{CRYSTAL_COMMAND}` command. Make sure you have crystal installed.")
      end

      regex = /\d+\.\d+\.\d+/
      output = `#{CRYSTAL_COMMAND} --version`
      match = regex.match(output)
      match && match[0]?
    end

    private def default_invitation
      "icr(#{@crystal_version}) > "
    end
  end
end
