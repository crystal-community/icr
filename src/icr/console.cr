module Icr
  # Responsible for interaction with user.
  class Console
    @crystal_version : String?

    def initialize(@debug = false)
      @command_stack = CommandStack.new
      @executer = Executer.new(@command_stack, debug)
      @crystal_version = get_crystal_version!
    end

    def start
      start("")
    end

    def start(code : String)
      process_input(code) unless code.empty?
      loop do
        input = ask_for_input
        process_input(input)
      end
    end

    private def process_input(input)
      if input.nil?
        # Ctrl+D was pressed, print new line before exit
        puts
        __exit__
      elsif %w(exit quit).includes?(input.to_s.strip)
        __exit__
      elsif input.to_s.strip != ""
        process_command(input.to_s)
      end
    end

    private def process_command(command : String)
      result = check_syntax(command)

      case result.status
      when :ok
        @command_stack.push(command)
        execute
      when :unexpected_eof, :unterminated_literal
        # If syntax is invalid because of unexpected EOF, or
        # we are still waiting for a closing bracket, keep asking for input
        next_command_part = ask_for_input(1)
        new_command = "#{command}\n#{next_command_part}"
        process_command(new_command)
      when :error
        # Give it the second try, validate the command in scope of entire file
        @command_stack.push(command)
        entire_file_result = check_syntax(@command_stack.to_code)
        if entire_file_result.status == :ok
          execute
        else
          @command_stack.pop
          puts result.error_message
        end
      else
        raise("Unknown SyntaxCheckResult status: #{result.status}")
      end
    end

    private def execute
      result = @executer.execute
      if result.success?
        print result.output
        if print_execution_result?
          puts " => #{result.value}"
        else
          puts " => ok"
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

    private def __exit__
      @executer.cleanup!
      exit 0
    end

    private def check_syntax(code)
      Crystal::Parser.parse(code)
      SyntaxCheckResult.new(:ok)
    rescue err : Crystal::SyntaxException
      case err.message.to_s
      when .includes?("EOF")
        SyntaxCheckResult.new(:unexpected_eof)
      when .includes?("unterminated")
        SyntaxCheckResult.new(:unterminated_literal)
      else
        SyntaxCheckResult.new(:error, err.message.to_s)
      end
    end
  end
end
