module HundredFive
  module Classes
    # Command class
    class Command
      # @return [String] command's name
      attr_reader :name

      # @return [HundredFive::Commands::Command] object associated with the command
      attr_reader :object

      # @return [String, nil] command's description
      attr_reader :description

      # @return [String, nil] command's category
      attr_reader :category

      # @return [Array<String>] where the bot listen for this command (private/public)
      attr_reader :listen

      # @return [Hash] command's arguments
      attr_reader :args

      # @return [Hash]
      attr_reader :subcommands

      LISTEN = {
        'public' => 'salon public',
        'private' => 'message privé'
      }

      # Initialize the Command object
      #
      # @param name [String] command's name
      # @param object [HundredFive::Commands::Command] command's object
      # @param description [String] command's description
      # @param category [String] command's category
      # @param listen [Array<String>] where to listen the command
      # @param args [Hash<Symbol, Hash<unknown>>] arguments to pass to the command
      # @param subcommands [Hash<Symbol, Command>]
      def initialize(name, object, description, category, listen, args, subcommands = {})
        @name        = name
        @object      = object
        @description = description
        @category    = category
        @listen = listen
        @args = args
        @subcommands = subcommands
      end

      def to_s
        parsed_args = ''
        unless @args == {}
          @args.each do |name, props|
            parsed_args << "  - <#{name}"
            parsed_args << "?" unless props[:boolean].nil?
            parsed_args = props[:extend].nil? ? parsed_args + ">" : parsed_args + "...>"
            parsed_args << " : #{props[:description]}"
            parsed_args << " (défaut: #{props[:default]})" unless props[:default] == nil
            parsed_args << "\n"
          end
        end
        output = "**• `#{CONFIG['bot']['prefix']}#@name` : #@description**\n"
        output << parsed_args
        output << "S'exécute en #{@listen.map {|mode| LISTEN[mode]}.join(' et ')}\n"
        output
      end
    end
  end
end
