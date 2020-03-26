require_relative 'lib/classes'
require_relative 'lib/models/assignments'
require_relative 'lib/models/messages'

module Coronagenda
  class Bot
    # List of all the commands and their functions
    attr_reader :commands

    # Bot version
    VERSION = CONFIG['meta']['version']

    def initialize(client)
      @client = client
      @commands = list_commands
      p @commands
    end

    # Trigger a command
    #
    # @param command_name [String] command's name
    # @param args [Array<String>] list of arguments passed to the command
    # @param context [Discordrb::Event::MessageEvent] the command context
    def handle_command(command_name, args, context)
      return unless context.channel.id == CONFIG['server']['commands_channel']

      command = @commands[command_name]
      if command.nil?
        context.send_message(
          "❓ *Commande inconnue. Faites #{CONFIG['bot']['prefix']}help pour avoir la liste complète des commandes autorisées.*"
        )
        return
      end

      unless context.author.role? CONFIG['server']['role']
        context.send_message(':x: *Vous n\'avez pas la permission d\'exécuter cette commande.*')
        return
      end
      
      parsed_args = {}

      i = 0
      command.args.each do |key, arg|
        gived = args[i]
        gived.strip! unless gived.nil?
        if gived == '' || gived.nil?
          if arg[:default].nil?
            context.send_message("Erreur d'argument : #{key} requis")
            return
          end
          parsed_args[key] = arg[:default] 
        else
          error = false
          unless arg[:type] == String
            begin
              gived = eval("#{arg[:type]}('#{gived}')")
            rescue ArgumentError
              error = true
            end
          end

          if error
            context.send_message("Erreur d'argument : #{key} doit être de type #{arg[:type]}")
            return
          end
          gived = args[i..].join(',') unless arg[:extend].nil?
          parsed_args[key] = gived
        end
        i += 1
      end
      command.object.exec(context, parsed_args)
    end

    # List all the commands
    def list_commands
      commands = {}
      prefix = CONFIG['bot']['prefix']
      Dir["src/commands/*.rb"].each do |path|
        resp = Regexp.new("([a-z0-9]+)\.rb$").match(path)
        if resp != nil && resp[1] != 'command'
          cmd_name = resp[1]
          cmd = load_command(cmd_name)
          commands[cmd_name] = Classes::Command.new(
            cmd_name,
            cmd,
            (cmd.const_defined?('USAGE') ? "#{prefix}#{cmd::USAGE}" : "#{prefix}#{cmd_name}"),
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