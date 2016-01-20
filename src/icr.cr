require "readline"
require "io/memory_io"

require "./icr/*"

module Icr
  # Unique value that separates program regular STDOUT from value returned by
  # the last command.
  DELIMITER = "|||||"
end

#Icr::Console.new.start
