require "option_parser"
require "../icr"

is_debug = false

def print_stamp
  puts "Author: #{Icr::AUTHOR}"
  puts "Homepage: #{Icr::HOMEPAGE}"
end

OptionParser.parse! do |parser|
  parser.banner = "Usage: icr [options]"

  parser.on("-v", "--version", "Show version") do
    puts "icr version #{Icr::VERSION}"
    print_stamp
    exit 0
  end

  parser.on("-h", "--help", "Show this help") do
    puts parser
    puts
    print_stamp
    exit 0
  end

  parser.on("-d", "--debug", "Run icr in debug mode") do
    is_debug = true
  end
end

Icr::Console.new(is_debug).start
