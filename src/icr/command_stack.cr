module Icr
  class CommandStack
    getter :commands

    def initialize
      @commands = [] of Command
    end

    def push(command : String)
      if command.strip =~ /^require\s/
        type = :require
      elsif command.strip =~ /^def\s/
        type = :method
      elsif command.strip =~ /^class\s/
        type = :class
      elsif command.strip =~ /^module\s/
        type = :module
      else
        type = :regular
      end
      @commands << Command.new(type, command)
    end

    def pop
      @commands.pop
    end

    def to_code
      <<-CRYSTAL
        #{code(:require)}
        #{code(:module)}
        #{code(:class)}
        #{code(:method)}

        def __icr_exec__
          #{code(:regular)}
        end

        puts "#{DELIMITER}\#{__icr_exec__.inspect}"
      CRYSTAL
    end

    def code(command_type)
      cmds = @commands.select { |cmd| cmd.type == command_type }.map &.value
      cmds.join("\n")
    end
  end
end
