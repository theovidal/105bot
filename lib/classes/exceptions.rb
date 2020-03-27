module Coronagenda
  class Exception < ::StandardError
  end

  module Classes
    class ExecutionError < Coronagenda::Exception
      attr_reader :waiter

      def initialize(waiter, message)
        super(message)
        @waiter = waiter
      end
    end

    class ArgumentError < Coronagenda::Exception
    end

    class CommandParsingError < Coronagenda::Exception
    end
  end
end
