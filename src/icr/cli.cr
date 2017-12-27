require "option_parser"
require "http/client"
require "semantic_version"
require "json"
require "yaml"
require "../icr"

XDG_CONFIG_HOME        = ENV.fetch("XDG_CONFIG_HOME", "~/.config")
CONFIG_HOME            = File.expand_path "#{XDG_CONFIG_HOME}/icr"
USAGE_WARNING_ACCEPTED = "#{CONFIG_HOME}/usage_warning_accepted"
LATEST_VERSION_FILE    = "#{CONFIG_HOME}/version.yml"

is_debug = false
libs = [] of String
usage_warning_accepted = File.exists? USAGE_WARNING_ACCEPTED
disable_update_available = false

def print_stamp
  puts "Author: #{Icr::AUTHOR}"
  puts "Homepage: #{Icr::HOMEPAGE}"
end

def print_usage_warning
  puts <<-WARN
  WARNING: ICR is not a full featured REPL.
  It works by building up a source file, compiling and re-running all of it on each input.
  That has side effects:

    * Current time and random numbers change retroactively
    * Files and network/database connections are reopened on every run
    * Running a sleep or benchmark will delay execution of next inputs
    * Unexpected behavior of fibers, channels, shell commands and maybe others

  Be careful while running your commands.

  You can disable this warning with --disable-usage-warning flag.
  WARN
end

def check_update_available
  if !File.exists?(LATEST_VERSION_FILE)
    Dir.mkdir_p CONFIG_HOME
    raw = YAML.dump({
      "latest_version"  => Icr::VERSION,
      "next_check_time" => Time.now + 1.day,
    })

    File.open(LATEST_VERSION_FILE, "w") do |f|
      f << raw
    end

    config = YAML.parse(raw)
    first_time = true
  else
    config = YAML.parse(File.open(LATEST_VERSION_FILE, "r"))
    first_time = false
  end

  return if !first_time && Time.now < config["check_next_time"].as_time

  response = HTTP::Client.get "https://api.github.com/repos/crystal-community/icr/releases/latest"
  if response.success?
    # Remain available rate limit (60 requests per hour is enough)
    latest_version = JSON.parse(response.body)["tag_name"].to_s.gsub("v", "")
    if SemanticVersion.parse(latest_version) <=> SemanticVersion.parse(Icr::VERSION) > 0
      puts <<-WARN
      ######################################################################################
      # icr #{latest_version} is available. You are on #{Icr::VERSION}.
      # You can disable update available check with --disable-update-available flag.
      # Please check it: https://github.com/crystal-community/icr/blob/master/CHANGELOG.md
      ######################################################################################
      WARN

      File.open(LATEST_VERSION_FILE, "w") do |f|
        data = config.as_h
        data["latest_version"] = latest_version
        data["next_check_time"] = Time.now + 1.day
        f << YAML.dump(data)
      end
    end
  end
rescue
  # do nothing
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
    Dir.mkdir_p CONFIG_HOME
    File.touch USAGE_WARNING_ACCEPTED
    usage_warning_accepted = true

    puts "Usage warning disabled. Run ICR again to continue."
    exit 0
  end

  parser.on("--disable-update-available", "Disable update available check") do
    disable_update_available = true
  end

  parser.on("--no-color", "Disable colorized output (also highlight)") do
    Colorize.enabled = false
  end
end

print_usage_warning unless usage_warning_accepted
check_update_available unless disable_update_available

code = libs.join(";")
Icr::Console.new(is_debug).start(code)
