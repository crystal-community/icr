require "spec"
require "../src/icr"

def icr(input : String)
  cmd = "#{Icr::ROOT_PATH}/bin/icr"

  io_in = MemoryIO.new(input)
  io_out = MemoryIO.new
  io_error = MemoryIO.new

  Process.run(cmd, nil, nil, false, true, io_in, io_out, io_error)
  io_out.to_s.strip
end
