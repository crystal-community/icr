require "readline"
require "io/memory_io"

require "./icr/*"

module Icr
  DELIMITER = "|||"
end

Icr::Console.new.start
