require "option_parser"
require "http/client"
require "semantic_version"
require "json"
require "yaml"
require "../icr"

XDG_CONFIG_HOME        = ENV.fetch("XDG_CONFIG_HOME", "~/.config")
CONFIG_HOME            = File.expand_path "#{XDG_CONFIG_HOME}/icr", home: true
USAGE_WARNING_ACCEPTED = "#{CONFIG_HOME}/usage_warning_accepted"
UPDATE_CHECK_DISABLED  = "#{CONFIG_HOME}/update_check_disabled"
UPDATE_CHECK_FILE      = "#{CONFIG_HOME}/update_check.yml"

is_debug = false
prompt_mode = "default"
libs = [] of String
usage_warning_accepted = File.exists? USAGE_WARNING_ACCEPTED
update_check_disabled = File.exists? UPDATE_CHECK_DISABLED

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

def check_for_update
  config = YAML.parse File.read(UPDATE_CHECK_FILE) if File.exists?(UPDATE_CHECK_FILE)
  latest_version = config.try &.["latest_version"]?.try &.as_s || Icr::VERSION
  check_next_time = config.try &.["next_check_time"]?.try &.as_time || Time.local

  if Time.local >= check_next_time
    response = HTTP::Client.get "https://api.github.com/repos/crystal-community/icr/releases/latest"
    latest_version = JSON.parse(response.body)["tag_name"].to_s.gsub("v", "") if response.success?
  end

  if SemanticVersion.parse(latest_version) <=> SemanticVersion.parse(Icr::VERSION) > 0
    puts <<-WARN
    ######################################################################################
    # icr #{latest_version} is available. You are on #{Icr::VERSION}.
    # You can disable update check with --disable-update-check flag.
    # Please check it: https://github.com/crystal-community/icr/blob/master/CHANGELOG.md
    ######################################################################################
    WARN
  end

  Dir.mkdir_p CONFIG_HOME
  yaml = YAML.dump({latest_version: latest_version, next_check_time: Time.local + 1.day})
  File.write(UPDATE_CHECK_FILE, yaml)
rescue
  nil
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

  parser.on("-p PROMPT", "--prompt-mode=PROMPT", "Switch prompt mode. \
            Pre-defined prompt modes are `default`, `simple` and `none`"
  ) do |mode|
    prompt_mode = mode.downcase
  end

  parser.on("--disable-usage-warning", "Disable usage warning") do
    Dir.mkdir_p CONFIG_HOME
    File.touch USAGE_WARNING_ACCEPTED
    usage_warning_accepted = true

    puts "Usage warning disabled. Run ICR again to continue."
    exit 0
  end

  parser.on("--disable-update-check", "Disable update check") do
    Dir.mkdir_p CONFIG_HOME
    File.touch UPDATE_CHECK_DISABLED
    update_check_disabled = true

    puts "Update check disabled. Run ICR again to continue."
    exit 0
  end

  parser.on("--no-color", "Disable colorized output (also highlight)") do
    Colorize.enabled = false
  end
end

print_usage_warning unless usage_warning_accepted
check_for_update unless update_check_disabled

code = libs.join(";")
Icr::Console.new(debug: is_debug, prompt_mode: prompt_mode).start(code)
