require_relative 'lib/classes'
require_relative 'lib/models/agendas'
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
    # @param commands [Array<String>] the commands and subcommands passed
    # @param args [Array<String>] list of arguments passed to the command
    # @param context [Discordrb::Event::MessageEvent] the command context
    def handle_command(commands, args, context)
      begin
        command = nil
        sub = false
        commands.each do |input|
          command = sub ? command.subcommands[input] : @commands[input]
          raise Classes::CommandParsingError.new(
            "**:question: La commande #{CONFIG['bot']['prefix']}#{input} est inconnue.**\n\n" +
            "Exécutez #{CONFIG['bot']['prefix']}help pour avoir la liste complète des commandes autorisées."
          ) if command.nil?
          args = [] if input == args[0]
          input == commands[-1] ? break : sub = true
        end
        p command
        if context.channel.private?
          return unless command.listen.include?('private')
        else
          return unless command.listen.include?('public')
        end

        unless context.channel.private?
          authorized = false
          context.user.roles.each do |role|
            authorized = true if CONFIG['server']['roles'].include?(role.id)
          end
          raise Classes::CommandParsingError.new(
            "**:x: Vous n'avez pas la permission d'intéragir avec le robot.**\n\n" +
            "Contactez un administateur pour obtenir plus de détails."
          ) unless authorized
        end

        parsed_args = {}
        i = 0
        command.args.each do |key, arg|
          gived = args[i]
          gived.strip! unless gived.nil?
          if gived == '' || gived.nil?
            raise Classes::ArgumentError.new("`#{key}` est un argument obligatoire.") if arg[:default].nil?
            parsed_args[key] = arg[:boolean].nil? ? arg[:default] : !arg[:default].zero?
          else
            unless arg[:type] == String
              begin
                gived = eval("#{arg[:type]}('#{gived}')")
              rescue ArgumentError
                raise Classes::ArgumentError.new("`#{key}` doit être de type `#{arg[:type]}`")
              end
            end

            gived = args[i..].join(',') unless arg[:extend].nil?
            parsed_args[key] = arg[:boolean].nil? ? gived : !gived.zero?
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
        context.author.pm.send_embed('', Utils.embed(
          description:
            "**#{CONFIG['messages']['error_emoji']} Erreur dans les arguments de la commande : #{e.message}**\n\n" +
            "Pour en savoir plus sur les commandes et leurs arguments, exécutez `#{CONFIG['bot']['prefix']}help`.",
          color: 12000284
        ))
      rescue Classes::ExecutionError => e
        if e.waiter.nil?
          context.author.pm.send_embed('', Utils.embed(
            description:
              "**#{CONFIG['messages']['error_emoji']} Erreur dans l'exécution de la commande : #{e.message}**",
            color: 12000284
          ))
        else
          e.waiter.error("Erreur dans l'exécution de la commande : #{e.message}")
        end
      end
    end

    # List all the commands
    def list_commands(base = 'commands')
      commands = {}
      Dir["src/#{base}/*.rb"].each do |path|
        resp = Regexp.new("([a-z0-9]+)\.rb$").match(path)
        if resp != nil && resp[1] != 'command'
          cmd_name = resp[1]
          cmd_path = "#{base}/#{cmd_name}"
          cmd = load_command(cmd_path)
          subcommands = cmd::SUBCOMMANDS ? list_commands(cmd_path) : {}

          commands[cmd_name] = Classes::Command.new(
            cmd_name,
            cmd,
            (cmd::DESC),
            (cmd::CATEGORY),
            (cmd::LISTEN),
            (cmd::ARGS),
            subcommands
          )
        end
      end
      commands
    end

    # Load a command from the files
    #
    # @param command [String] the command's name
    def load_command(command)
      require_relative "src/#{command}"
      name = command.split('/')[-1]
      eval("Commands::#{name.capitalize}")
    end
  end
end
