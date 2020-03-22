require_relative 'lib/classes'
require_relative 'lib/data'
require_relative 'lib/models/assignments'
require_relative 'lib/models/messages'

module Coronagenda
  class Bot
    # List of all the commands and their functions
    attr_reader :commands

    # Bot version
    VERSION = $config['bot']['version']

    # Library used for the bot
    LIBRARY = 'DiscordRB'

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
      return unless context.channel.id == $config['server']['commands_channel']

      command = @commands[command_name]
      if command.nil?
        context.send_message(
          "❓ *Commande inconnue. Faites #{$config['bot']['prefix']}help pour avoir la liste complète des commandes autorisées.*"
        )
        return
      end

      if context.author.role? $config['server']['role']
        command.function.call(context, args)
      else
        context.send_message(':x: *Vous n\'avez pas la permission d\'exécuter cette commande.*')
      end
    end

    # List all the commands
    def list_commands
      commands = {}
      prefix = $config['bot']['prefix']
      Dir["src/commands/*.rb"].each do |path|
        resp = Regexp.new("([a-z0-9]+)\.rb$").match(path)
        if resp != nil && resp[1] != 'command'
          cmd_name = resp[1]
          cmd = load_command(cmd_name)
          data = {
            name:     cmd_name,
            function: -> (context, args) { cmd.exec(context, args) },
            desc:     (cmd::DESCRIPTION),
            usage:    (cmd.const_defined?('USAGE') ? "#{prefix}#{cmd::USAGE}" : "#{prefix}#{cmd_name}")
          }
          commands[cmd_name] = Classes::Command.new(data)
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