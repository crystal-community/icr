require "readline"
require "io/memory_io"

require "./icr/version"
require "./icr/command"
require "./icr/command_stack"
require "./icr/console"

module Icr
  # Unique value that separates program regular STDOUT from value returned by
  # the last command.
  DELIMITER = "|||||"
end

