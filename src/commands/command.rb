module HundredFive
  module Commands
    class Command
      # @return [String] Description of the command, to provide help about the goal it serves
      DESC = 'Socle des commandes'

      # @return [String] The command category, used for help
      CATEGORY = 'default'

      # @return [Array<String>] The context in which the command will listen. Can be :
      #   - public : in a server channel
      #   - private : in a private message channel
      # Can be one of them or both.
      LISTEN = %w[public]

      # @return [Hash<Symbol, Hash<unknown>>] Arguments the command accepts.
      # They are provided by the user and comma-separated.
      #
      # Values for each arguments are :
      # - description : a brief description of the argument
      # - type : the type of the argument, generally Integer, String or Float
      # - boolean : if the provided Integer should be interpreted as a boolean
      # - extends : if the rest of the message should be interpreted as a single argument, ignoring commas and line breaks
      # - default : a default value for the argument (nil if required)
      ARGS = {}

      # Execute the requested command.
      #
      # @param context [Discordrb::Events::MessageEvent] The context in which the command is executed
      # @param args [Hash<Symbol, unknown>] List of arguments
      def self.exec(context, args)
        # --
      end
    end
  end
end
