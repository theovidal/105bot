module Coronagenda
  module Classes
    class ExecutionError < ::StandardError
      attr_reader :waiter

      def initialize(waiter, message)
        super(message)
        @waiter = waiter
      end
    end

    class ArgumentError < ::StandardError
    end

    class CommandParsingError < ::StandardError
    end

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

      # @return [Hash] command's arguments
      attr_reader :args

      # Initialize the Command object
      #
      # @param data [Hash] command data
      def initialize(name, object, usage, description, args)
        @name        = name
        @object      = object
        @usage       = usage
        @description = description
        @args = args
      end

      def to_s
        "**• `#{CONFIG['bot']['prefix']}#@name` : #@description**\nUtilisation : `#@usage`"
      end
    end

    class Waiter
      attr_reader :text

      def initialize(context, text, subtext = '')
        @context = context
        @text = text
        @subtext = subtext
        @color = CONFIG['messages']['wait_color']
        @msg = context.send_embed('', generate_msg)
      end

      def edit_subtext(text)
        @subtext = text
        @msg.edit('', generate_msg)
      end

      def finish(text, subtext = '')
        @text = "#{CONFIG['messages']['finished_emoji']} #{text}"
        @subtext = subtext
        @color = CONFIG['messages']['color']
        @msg.edit('', generate_msg)
      end

      def error(text, subtext = '')
        @text = "#{CONFIG['messages']['error_emoji']} #{text}"
        @subtext = subtext
        @color = CONFIG['messages']['error_color']
        @msg.edit('', generate_msg)
      end

      private

      def generate_msg
        Utils.embed(
          description: "**#@text**\n\n#@subtext",
          color: @color
        )
      end
    end
  end
end