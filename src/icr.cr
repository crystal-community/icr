require "readline"
require "tempfile"
require "io/memory_io"
require "secure_random"

# Require minimal to use Parser
#
require "compiler/crystal/codegen/**"
require "compiler/crystal/core_ext/**"
require "compiler/crystal/syntax/**"
require "compiler/crystal/semantic/**"
require "compiler/crystal/macros/**"
#require "compiler/crystal/tools/**"
require "compiler/crystal/crystal_path"
require "compiler/crystal/program"
require "compiler/crystal/compiler"
require "compiler/crystal/command"
#require "compiler/crystal/config"
#require "compiler/crystal/exception"
#require "compiler/crystal/primitives"
#require "compiler/crystal/types"

#require "compiler/crystal/**"

require "./icr/command"
require "./icr/command_stack"
require "./icr/executer"
require "./icr/execution_result"
require "./icr/syntax_check_result"
require "./icr/console"

module Icr
  VERSION = "0.2.7"
  AUTHOR = "Potapov Sergey"
  HOMEPAGE = "https://github.com/greyblake/crystal-icr"

  # Unique value that separates program regular STDOUT from value returned by
  # the last command.
  DELIMITER = "|||YIH22hSkVQN|||"
  CRYSTAL_COMMAND = "crystal"
  ROOT_PATH = File.expand_path("../..", __FILE__)
end
