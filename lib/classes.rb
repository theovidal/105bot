module Coronagenda
  module Classes
    # Command class
    class Command
      # @return [String] command's name
      attr_reader :name

      # @return [Proc] command's function to trigger when it's called
      attr_reader :function

      # @return [String, nil] command's usage, for the help
      attr_reader :usage

      # @return [String, nil] command's description
      attr_reader :description

      # Initialize the Command object
      #
      # @param data [Hash] command data
      def initialize(data)
        @name        = data[:name]
        @function    = data[:function]
        @usage       = data[:usage]
        @description = data[:description]
      end

      def to_s
        "• `#{$config['bot']['prefix']}#@name` : #@description\nUtilisation : `#@usage`"
      end
    end
  end
end