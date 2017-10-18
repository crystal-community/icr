require "option_parser"
require "../icr"
require "./settings"

is_debug = false
libs = [] of String
settings = Icr::Settings.load

def print_stamp
  puts "Author: #{Icr::AUTHOR}"
  puts "Homepage: #{Icr::HOMEPAGE}"
end

def print_usage_warning
  puts <<-WARN
  WARNING: ICR is not a real REPL and may have side effects.
  Please read the documentation carefully and be sure you understand how it works before using it.
  Disable this warning with --disable-usage-warning.
  WARN
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

  parser.on("-r FILE", "--require=FILE", "auto require FILE") do |filename|
    libs.push(%{require "#{filename}"})
  end

  parser.on("--disable-usage-warning", "Disable usage warning") do
    settings.print_usage_warning = false
    settings.save
  end
end

print_usage_warning if settings.print_usage_warning

code = libs.join(";")
Icr::Console.new(is_debug).start(code)
