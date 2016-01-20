module Icr
  class Command
    getter :type, :value

    def initialize(@type, @value)
    end
  end
end
