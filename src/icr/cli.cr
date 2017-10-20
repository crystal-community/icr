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
  WARNING: ICR is not a full featured REPL.
  It works by building up source file, compiling and re-running all of it on each input.
  That has side effects:

    * Current time and random numbers change retroactively
    * Files and network/database connections are reopened on every run
    * Running a sleep or benchmark will delay an execution of next inputs
    * Unexpected behavior of fibers, channels, shell commands and maybe others

  Be careful while running your commands.

  You can disable this warning with --disable-usage-warning flag.
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
