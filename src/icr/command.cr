module Icr
  # Command represents single user's input.
  # Properties:
  #   * value - actual input
  #   * type - type of input(require, class, module, method, regular, etc)
  class Command
    getter :type, :value

    def initialize(@type : Symbol, @value : String)
    end
  end
end
