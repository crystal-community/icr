require "yaml"

class Icr::Settings
  PATH = File.expand_path "~/.icr"

  YAML.mapping(
    print_usage_warning: {type: Bool, default: true},
  )

  def self.load
    settings = File.exists?(PATH) ? File.read(PATH) : "{}"
    Settings.from_yaml settings
  end

  def save
    File.write(PATH, to_yaml)
  end
end
