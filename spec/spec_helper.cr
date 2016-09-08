require "spec"
require "../src/icr"

# Execute icr command with the giving input and return stripped output.
def icr(input : String)
  icr(input, "")
end

# Optionally, you can pass flags to the icr command 
def icr(input : String, *args)
  cmd = ["#{Icr::ROOT_PATH}/bin/icr"]
  cmd.push(*args) unless args.empty?

  io_in = MemoryIO.new(input)
  io_out = MemoryIO.new
  io_error = MemoryIO.new

  Process.run(cmd.join(" "), nil, nil, false, true, io_in, io_out, io_error)
  io_out.to_s.strip
end
