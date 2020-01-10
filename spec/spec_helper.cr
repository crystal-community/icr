require "spec"
require "../src/icr"

# Execute icr command with the given input and return stripped output.
def icr(input : String, env : Hash(String, String) | Nil = nil)
  icr(input, "", env: env)
end

# Optionally, you can pass flags to the icr command
def icr(input : String, *args : String, env = nil)
  cmd = ["#{Icr::ROOT_PATH}/bin/icr"]
  cmd.push(*args) unless args.empty?

  io_in = IO::Memory.new(input)
  io_out = IO::Memory.new
  io_error = IO::Memory.new

  Process.run(cmd.join(" "), nil, env, false, true, io_in, io_out, io_error)
  io_out.to_s.strip
end

def within_temp_folder(path : String)
  FileUtils.mkdir_p path
  FileUtils.cd path
  yield
ensure
  FileUtils.rm_r path if Dir.exists?(path)
end
