require_relative 'command'

module HundredFive
  module Commands
    class Show < Command
      DESC = "Montrer l'agenda pour les x jours suivants le dernier message"
      ARGS = {
        number: {
          description: 'Nombre de jours à afficher',
          type: Integer,
          default: nil
        },
        includeWeek: {
          description: 'Inclure ou non les jours de week-end (Samedi et Dimanche)',
          type: Integer,
          boolean: true,
          default: 0
        }
      }

      def self.exec(context, args)
        args[:includeWeek] = !args[:includeWeek].zero?
        add_str = args[:number] == 1 ? "d'un jour supplémentaire" : "de #{args[:number]} jours supplémentaires"
        waiter = Classes::Waiter.new(context, ":inbox_tray: Affichage #{add_str} sur l'agenda, veuillez patienter...")

        last = Models::Messages.last
        day_delay = 0
        args[:number].to_i.times do |i|
          date = last[:date] + i + day_delay + 1
          if date.wday == 0 || date.wday == 6
            day_delay += 1
            redo
          end
          discord = context.bot.send_message(CONFIG['server']['output_channel'], date)

          model = Models::Messages.create do |message|
            message.date = date
            message.discord_id = discord.id
          end

          Models::Messages.refresh(context, model)
        end

        waiter.finish("Affichage #{add_str} sur l'agenda effectué.")
      end
    end
  end
end
