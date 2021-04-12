module Icr
  # Command represents single user's input.
  # Properties:
  #   * value - actual input
  #   * type - type of input(require, class, module, method, regular, etc)
  class Command
    getter :type, :value
    property vars_cmd = ""

    def initialize(@type : Symbol, @value : String)
    end

    def regular?
      type == :regular
    end

    def parsed_value
      res = value
      if regular?
        res = "_r = (#{value});
               Base64.strict_encode({
                 result: _r.inspect,
                 serialized: %Q(#{encoded_var_value("_r")} #{encoded_var_value(calc_var_name)}) }.to_json)"
        res = vars_cmd unless vars_cmd.empty?
      end
      res
    end

    def encoded_var_value(var_name : String)
      return "" if var_name.empty?

      serialized = "\#{Crystalizer::JSON.serialize(#{var_name}).inspect}"
      var_type = "\#{typeof(#{var_name})}"
      "#{var_name} = Crystalizer::JSON.deserialize(#{serialized}, #{var_type}); "
    end

    # TODO: calc all variable names from the command
    def calc_var_name
      value.match(/(\w+) ?= ?(.*)/).try(&.[1]).to_s
    end
  end
end
