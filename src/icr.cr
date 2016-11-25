require "readline"
require "tempfile"
require "io/memory"
require "secure_random"

require "compiler/crystal/syntax"

require "./icr/command"
require "./icr/command_stack"
require "./icr/executer"
require "./icr/execution_result"
require "./icr/syntax_check_result"
require "./icr/console"

module Icr
  VERSION = "0.2.13"
  AUTHOR = "Potapov Sergey"
  HOMEPAGE = "https://github.com/greyblake/crystal-icr"

  # Unique value that separates program regular STDOUT from value returned by
  # the last command.
  DELIMITER = "|||YIH22hSkVQN|||"
  CRYSTAL_COMMAND = "crystal"
  ROOT_PATH = File.expand_path("../..", __FILE__)
end
