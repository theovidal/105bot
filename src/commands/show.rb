require_relative 'command'

module Coronagenda
  module Commands
    class Show < Command
      DESC = "Montrer l'agenda pour les x jours suivants le dernier message"
      USAGE = 'show <x> <weekend?>'

      def self.parse_args(args)
        args[1] = 0 if args[1].nil?
        {
          number: args[0].to_i,
          includeWeek: !args[1].to_i.zero?
        }
      end

      def self.exec(context, args)
        add_str = args[:number] == 1 ? "d'un jour supplémentaire" : "de #{args[:number]} jours supplémentaires"
        waiter = context.send_embed('', Utils.embed(
          description: ":inbox_tray: Affichage #{add_str} sur l'agenda, veuillez patienter..."
        ))

        last = Models::Messages.last
        args[:number].to_i.times do |i|
          date = last[:date] + i + 1
          if date.wday == 0 || date.wday == 6
            i += 1
            redo
          end
          discord = context.bot.send_message(CONFIG['server']['output_channel'], date)

          model = Models::Messages.create do |message|
            message.date = date
            message.discord_id = discord.id
          end

          Models::Messages.refresh(context, model)
        end

        waiter.edit('', Utils.embed(
          description: ":white_check_mark: Affichage #{add_str} sur l'agenda effectué."
        ))
      end
    end
  end
end
