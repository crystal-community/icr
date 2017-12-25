module Icr
  # Responsible for interaction with user.
  class Console
    @crystal_version : String?

    def initialize(debug = false)
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
      elsif input.to_s.strip == "paste"
        paste_mode()
      elsif input.to_s.strip == "reset"
        @command_stack.clear
        puts "Crystal environment reset."
      elsif input.to_s.strip == "debug"
        @executer.debug = !@executer.debug
        puts "Debug: #{@executer.debug}"
      elsif input.to_s.strip != ""
        process_command(input.to_s)
      end
    end

    private def paste_mode
      puts "# Entering paste mode (ctrl-D to finish)"
      input = String.build do |input|
        loop do
          input_line = Readline.readline

          if input_line.nil?
            puts "\n\n# Ctrl-D was pressed, exiting paste mode...\n"
            break
          end

          input << input_line
          input << "\n"
        end
      end

      if !input.blank?
        process_command(input.to_s)
      else
        puts "\n# Nothing pasted, nothing gained\n"
      end
    end

    private def last_value
      @executer.execute.value
    end

    private def process_command(command : String)
      command = command.to_s.gsub(/\b__\b/) { last_value.to_s.strip }
      result = check_syntax(command)
      process_result(result, command)
    end

    private def process_result(result : SyntaxCheckResult, command : String)
      case result.status
      when :ok
        @command_stack.push(command)

        if Colorize.enabled?
          # Move the cursor at the first line of command
          command.lines.size.times { STDOUT << "\e[A\e[K" }

          STDOUT << Highlighter.new(default_invitation).highlight(command)
        end

        execute
      when :unexpected_eof, :unterminated_literal
        # If syntax is invalid because of unexpected EOF, or
        # we are still waiting for a closing bracket, keep asking for input
        continue_processing(command)
      when :error
        # Give it the second try, validate the command in scope of entire file
        @command_stack.push(command)
        entire_file_result = check_syntax(@command_stack.to_code)
        case entire_file_result.status
        when :ok
          execute
        when :unexpected_eof
          @command_stack.pop
          process_result(entire_file_result, command)
        else
          @command_stack.pop
          puts result.error_message
        end
      else
        raise("Unknown SyntaxCheckResult status: #{result.status}")
      end
    end

    # If the command has been processed, but not complete
    private def continue_processing(command)
      next_command_part = ask_for_input(1)
      new_command = "#{command}\n#{next_command_part}"
      process_command(new_command)
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
      if `which #{CRYSTAL_COMMAND}`.strip == ""
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
      when .includes?("unterminated char literal")
        # catches error for 'aa' and returns compiler error
        SyntaxCheckResult.new(:ok)
      when .includes?("unterminated")
        # catches unterminated hashes and arrays
        SyntaxCheckResult.new(:unterminated_literal)
      else
        SyntaxCheckResult.new(:error, err.message.to_s)
      end
    end
  end
end
