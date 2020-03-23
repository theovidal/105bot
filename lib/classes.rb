module Coronagenda
  module Classes
    # Command class
    class Command
      # @return [String] command's name
      attr_reader :name

      # @return [Coronagenda::Commands::Command] object associated with the command
      attr_reader :object

      # @return [String, nil] command's usage, for the help
      attr_reader :usage

      # @return [String, nil] command's description
      attr_reader :description

      # Initialize the Command object
      #
      # @param data [Hash] command data
      def initialize(name, object, usage, description)
        @name        = name
        @object      = object
        @usage       = usage
        @description = description
      end

      def to_s
        "**• `#{$config['bot']['prefix']}#@name` : #@description**\nUtilisation : `#@usage`"
      end
    end
  end
end