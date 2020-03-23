require_relative 'command'

module Coronagenda
  module Commands
    class Hide < Command
      DESCRIPTION = 'Masquer les x derniers jours affichés'
      USAGE = 'hide <x>'

      def self.parse_args(args)
        {
          number: args[0].to_i
        }
      end

      def self.exec(context, args)
        context.send_message(':outbox_tray: *Retrait en cours, veuillez patienter...*')
        messages = Models::Messages.reverse(:id).limit(args[:number])
        messages.each do |message|
          context.bot.channel($config['server']['output_channel']).message(message[:discord_id]).delete
          message.delete
        end
        context.send_message(':white_check_mark: *Retrait terminé*')
      end
    end
  end
end
