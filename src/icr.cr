require "readline"
require "tempfile"
require "io/memory_io"
require "compiler/crystal/**"

require "./icr/version"
require "./icr/command"
require "./icr/command_stack"
require "./icr/console"

module Icr
  # Unique value that separates program regular STDOUT from value returned by
  # the last command.
  DELIMITER = "|||YIH22hSkVQN|||"

  ROOT_PATH = File.expand_path("../..", __FILE__)
end

