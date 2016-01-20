require "../spec_helper"

describe Icr::CommandStack do
  it "pushes and pops commands, generates proper crystal code" do
    stack = Icr::CommandStack.new
    stack.push("puts 10")
    stack.push("require \"io\"")
    stack.push("invalid command")
    stack.pop # remove last command

    code = stack.to_code
    code.should eq <<-CODE
require "io"

def __icr_exec__
puts 10
end

puts "|||||\#{__icr_exec__.inspect}"
    CODE
  end
end
