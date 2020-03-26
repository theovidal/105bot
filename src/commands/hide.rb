require_relative 'command'

module Coronagenda
  module Commands
    class Hide < Command
      DESC = 'Masquer les x derniers jours affichés'
      USAGE = 'hide <x>'

      def self.parse_args(args)
        {
          number: args[0].to_i
        }
      end

      def self.exec(context, args)
        last_str = args[:number] == 1 ? 'du dernier jour' : "des #{args[:number]} derniers jours"
        waiter = context.send_embed('', Utils.embed(
          description: ":outbox_tray: Retrait #{last_str} de l'agenda, veuillez patienter..."
        ))

        messages = Models::Messages.reverse(:id).limit(args[:number])
        messages.each do |message|
          context.bot.channel(CONFIG['server']['output_channel']).message(message[:discord_id]).delete
          message.delete
        end

        waiter.edit('', Utils.embed(
          description: ":white_check_mark: Retrait #{last_str} de l'agenda effectué."
        ))
      end
    end
  end
end
