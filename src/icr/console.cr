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
        process_command(input.to_s)
      end
    end

    private def process_command(command : String)
      # Validate syntax
      Crystal::Parser.parse(command)
      @command_stack.push(command)
      execute
    rescue err : Crystal::SyntaxException
      if err.message =~ /EOF/
        # If syntax is invalid because of unexpected EOF, ask for a new input
        next_command_part = ask_for_input(1)
        new_command = "#{command}\n#{next_command_part}"
        process_command(new_command)
      else
        puts err.message
      end
    end

    private def execute
      result = @executer.execute
      if result.success?
        print result.output
        if print_execution_result?
          puts " => #{result.value}"
        else
          puts " => OK"
        end
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

    private def print_execution_result?
      @command_stack.commands.last.type == :regular
    end
  end
end
