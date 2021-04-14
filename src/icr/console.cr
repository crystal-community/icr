lib LibReadline
  fun rl_insert_text(text : UInt8*)
  fun rl_redisplay()
  $rl_point : Int32
end

module Readline
  def rl_insert_text(text : String)
    LibReadline.rl_insert_text(text)
  end

  def rl_redisplay
    LibReadline.rl_redisplay
  end

  def rl_point
    LibReadline.rl_point
  end
end

module Icr
  # Responsible for interaction with user.
  class Console
    @crystal_version : String?
    @level : Int32

    def initialize(debug = false, @prompt_mode = "default")
      @command_stack = CommandStack.new
      @executer = Executer.new(@command_stack, debug)
      @crystal_version = get_crystal_version!
      @level = 0
    end

    def start
      start("")
    end

    def start(code : String)
      process_input(code) unless code.empty?

      if Colorize.enabled?
        (32..256).each do |i|
          begin
            Readline.bind_key i.chr do
              invitation = prompt
              LibReadline.rl_insert_text "#{i.chr}"
              LibReadline.rl_redisplay
              indent = @level * 2
              line = Readline.line_buffer.as String
              off = line.size - Readline.rl_point
              (line.size - off).times { STDOUT << "\e[D" }
              highlighter = Highlighter.new("")
              STDOUT << highlighter.highlight(line).strip + "\e[0m"
              puts
              STDOUT << "\e[A"
              (line.size + invitation.size + indent - off).times { STDOUT << "\e[C" }
              0
            end
          rescue
          end
        end
      end
      loop do
        input = ask_for_input
        process_input(input)
        if Colorize.enabled?
          STDOUT << "\e[A"
        end
      end
    end

    private def process_input(input)
      if input.nil?
        # Ctrl+D was pressed, print new line before exit
        puts
        __exit__
      elsif input.to_s.strip == "#exit" || input.to_s.strip == "#quit"
        __exit__
      elsif input.to_s.strip == "#paste"
        paste_mode()
      elsif input.to_s.strip == "#reset"
        @command_stack.clear
        puts "Crystal environment reset."
      elsif input.to_s.strip == "#debug"
        @executer.debug = !@executer.debug
        puts "Debug: #{@executer.debug}"
      elsif input.to_s.strip == "#help"
        puts <<-EOF
        All commands:
         #exit, #quit      Exit ICR.
         #paste            Enter paste mode.
         #reset            Reset the environment.
         #debug            Enter debug mode.
         #help             Print this message.
        EOF
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
          if Colorize.enabled?
            puts " => #{Highlighter.new("").highlight(result.value.as String).strip}"
          else
            puts " => #{result.value}"
          end
        else
          puts " => ok"
        end
      else
        puts result.error_output

        puts if Colorize.enabled?
      end
    end

    private def ask_for_input(level = 0)
      @level = level
      invitation = prompt + "  " * level
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

    private def prompt
      case @prompt_mode
      when "default"
        "icr(#{@crystal_version}) > "
      when "simple"
        "> "
      when "none"
        ""
      else
        raise ArgumentError.new "wrong prompt mode"
      end
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
