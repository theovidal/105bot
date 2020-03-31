require_relative 'lib/classes'
require_relative 'lib/models/assignments'
require_relative 'lib/models/messages'

module HundredFive
  class Bot
    # List of all the commands and their functions
    attr_reader :commands

    # Bot version
    VERSION = CONFIG['meta']['version']

    def initialize(client)
      @client = client
      @commands = list_commands
    end

    # Trigger a command
    #
    # @param command_name [String] command's name
    # @param args [Array<String>] list of arguments passed to the command
    # @param context [Discordrb::Event::MessageEvent] the command context
    def handle_command(command_name, args, context)
      return unless context.channel.id == CONFIG['server']['commands_channel']

      begin
        command = @commands[command_name]
        raise Classes::CommandParsingError.new("**:x: Vous n'avez pas la permission d'intéragir avec le robot.**\n\nContactez un administateur pour obtenir plus de détails.") unless context.author.role? CONFIG['server']['role']
        raise Classes::CommandParsingError.new("**:question: La commande #{CONFIG['bot']['prefix']}#{command_name} est inconnue.**\n\nExécutez #{CONFIG['bot']['prefix']}help pour avoir la liste complète des commandes autorisées.") if command.nil?

        parsed_args = {}
        i = 0
        command.args.each do |key, arg|
          gived = args[i]
          gived.strip! unless gived.nil?
          if gived == '' || gived.nil?
            raise Classes::ArgumentError.new("`#{key}` est un argument obligatoire.") if arg[:default].nil?
            parsed_args[key] = arg[:default]
          else
            unless arg[:type] == String
              begin
                gived = eval("#{arg[:type]}('#{gived}')")
              rescue ArgumentError
                raise Classes::ArgumentError.new("`#{key}` doit être de type `#{arg[:type]}`")
              end
            end

            gived = args[i..].join(',') unless arg[:extend].nil?
            parsed_args[key] = gived
          end
          i += 1
        end
        command.object.exec(context, parsed_args)
      rescue Classes::CommandParsingError => e
        context.send_embed('', Utils.embed(
          description: e.message,
          color: 12000284
        ))
      rescue Classes::ArgumentError => e
        context.send_embed('', Utils.embed(
          description: "**#{CONFIG['messages']['error_emoji']} Erreur dans les arguments : #{e.message}**\n\nPour en savoir plus sur les commandes et leurs arguments, exécutez `#{CONFIG['bot']['prefix']}help`.",
          color: 12000284
        ))
      rescue Classes::ExecutionError => e
        e.waiter.error("Erreur dans l'exécution de la commande : #{e.message}")
      end
    end

    # List all the commands
    def list_commands
      commands = {}
      Dir["src/commands/*.rb"].each do |path|
        resp = Regexp.new("([a-z0-9]+)\.rb$").match(path)
        if resp != nil && resp[1] != 'command'
          cmd_name = resp[1]
          cmd = load_command(cmd_name)
          commands[cmd_name] = Classes::Command.new(
            cmd_name,
            cmd,
            (cmd::DESC),
            (cmd::ARGS)
          )
        end
      end
      commands
    end

    # Load a command from the files
    #
    # @param command [String] the command's name
    def load_command(command)
      require_relative "src/commands/#{command}"
      eval("Commands::#{command.capitalize}")
    end
  end
end