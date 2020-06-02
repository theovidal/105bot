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

      # @return [Hash] command's arguments
      attr_reader :args

      # Initialize the Command object
      #
      # @param data [Hash] command data
      def initialize(name, object, description, category, args)
        @name        = name
        @object      = object
        @description = description
        @category    = category
        @args = args
      end

      def to_s
        parsed_args = ''
        unless @args == {}
          parsed_args = "Arguments : \n"
          @args.each do |name, props|
            parsed_args << "  - <#{name}"
            parsed_args << "?" unless props[:boolean].nil?
            parsed_args = props[:extend].nil? ? parsed_args + ">" : parsed_args + "...>"
            parsed_args << " : #{props[:description]}"
            parsed_args << " (défaut: #{props[:default]})" unless props[:default] == nil
            parsed_args << "\n"
          end
        end
        "**• `#{CONFIG['bot']['prefix']}#@name` : #@description**\n#{parsed_args}"
      end
    end
  end
end
