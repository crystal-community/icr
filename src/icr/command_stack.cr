module Icr
  class CommandStack
    getter :commands

    def initialize
      @commands = [] of Command
    end

    def push(command : String)
      if command.strip =~ /require\s+"[\w\/]+"/
        type = :require
      else
        type = :regular
      end
      @commands << Command.new(type, command)
    end

    def pop
      @commands.pop
    end

    def to_code
      require_commands = @commands.select { |cmd| cmd.type == :require }.map &.value
      regular_commands = @commands.select { |cmd| cmd.type == :regular }.map &.value

      require_code = require_commands.join("\n")
      regular_code = regular_commands.join("\n")

      <<-CODE
        #{require_code}

        def __icr_exec__
          #{regular_code}
        end

        puts "#{DELIMITER}\#{__icr_exec__.inspect}"
      CODE
    end

  end
end
