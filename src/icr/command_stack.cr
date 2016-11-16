module Icr
  # CommandStack - is a collection is a user's input.
  # It distinguishes input of different types and at the end generates
  # crystal source code, that can be executed.
  class CommandStack
    getter :commands

    def initialize
      @commands = [] of Command
    end

    # Add new command.
    def push(command : String)
      if command.strip =~ /^require\s/
        type = :require
      elsif command.strip =~ /^def\s/
        type = :method
      elsif command.strip =~ /^class\s/
        type = :class
      elsif command.strip =~ /^module\s/
        type = :module
      elsif command.strip =~ /^record\s/
        type = :record
      elsif command.strip =~ /^struct\s/
        type = :struct
      elsif command.strip =~ /^alias\s/
        type = :alias
      else
        type = :regular
      end
      @commands << Command.new(type, command)
    end

    # Pop the last command. It's used in cases if the last command results into error.
    def pop
      @commands.pop
    end

    # Generate crystal source code, based on the command in the stack.
    def to_code
      code =
        <<-CRYSTAL
        #{code(:require)}
        #{code(:module)}
        #{code(:class)}
        #{code(:method)}
        #{code(:record)}
        #{code(:struct)}
        #{code(:alias)}

        def __icr_exec__
        #{code(:regular, 1)}
        end

        puts "#{DELIMITER}\#{__icr_exec__.inspect}"
        CRYSTAL
      code.strip
    end

    private def code(command_type, indent_level = 0)
      cmds = @commands.select { |cmd| cmd.type == command_type }.map &.value
      cmds.map { |cmd| ("  " * indent_level) + cmd }.join("\n")
    end
  end
end
