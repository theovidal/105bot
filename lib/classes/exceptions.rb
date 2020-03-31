module HundredFive
  class Exception < ::StandardError
  end

  module Classes
    class ExecutionError < HundredFive::Exception
      attr_reader :waiter

      def initialize(waiter, message)
        super(message)
        @waiter = waiter
      end
    end

    class ArgumentError < HundredFive::Exception
    end

    class CommandParsingError < HundredFive::Exception
    end
  end
end
