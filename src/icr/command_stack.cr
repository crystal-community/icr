module Icr
  # CommandStack - is a collection is a user's input.
  # It distinguishes input of different types and at the end generates
  # crystal source code, that can be executed.
  class CommandStack
    getter :commands

    def initialize
      @commands = [] of Command
    end

    def clear
      @commands.clear
    end

    # Add new command.
    def push(command : String)
      case command.strip
      when .match /^require\s/
        type = :require
      when .match /^def\s/
        type = :method
      when .match /^class\s/
        type = :class
      when .match /^module\s/
        type = :module
      when .match /^enum\s/
        type = :enum
      when .match /^record\s/
        type = :record
      when .match /^struct\s/
        type = :struct
      when .match /^alias\s/
        type = :alias
      when .match /^[A-Z]([A-Za-z0-9_]+)?\s*=[^=~]/
        type = :constant_assignment
      when .match /^macro\s/
        type = :macro
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
        #{code(:enum)}
        #{code(:class)}
        #{code(:method)}
        #{code(:record)}
        #{code(:struct)}
        #{code(:alias)}
        #{code(:constant_assignment)}
        #{code(:macro)}

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
