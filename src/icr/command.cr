module Icr
  # Command represents single user's input.
  # Properties:
  #   * value - actual input
  #   * type - type of input(require, class, module, method, regular, etc)
  class Command
    getter :type, :value
    property cached_results = ""

    def initialize(@type : Symbol, @value : String)
    end

    def regular?
      type == :regular
    end

    def parsed_value
      return value unless regular?

      run_cmd = "__previous_result = (#{value});
             Base64.strict_encode({
               result: __previous_result.inspect,
               serialized: %Q(#{encoded_var_value("__previous_result")} #{encoded_var_value(calc_var_name)})
             }.to_json) + #{DELIMITER.inspect}"
      cached_results.empty? ? run_cmd : cached_results
    end

    def encoded_var_value(var_name : String)
      return "" if var_name.empty?

      serialized = "\#{Crystalizer::JSON.serialize(#{var_name}).inspect}"
      var_type = "\#{typeof(#{var_name})}"
      "#{var_name} = Crystalizer::JSON.deserialize(#{serialized}, #{var_type}); "
    end

    # TODO: calc all variable names from the command
    def calc_var_name
      value.gsub(/\"(.*?)\"/, "")
           .match(/(\w+) ?= ?(.*)/)
           .try(&.[1]).to_s
    end
  end
end
