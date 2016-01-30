module Icr
  # Result of execution user's input, returned by Executer.
  class ExecutionResult
    getter :success, :value, :output, :error_output

    def initialize(@success : Bool, @value : (String|Nil), @output : (String|Nil), @error_output : (String|Nil))
    end

    def success?
      @success
    end
  end
end
