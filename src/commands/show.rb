require_relative 'command'

module Coronagenda
  module Commands
    class Show < Command
      DESC = "Montrer l'agenda pour les x jours suivants le dernier message"
      USAGE = 'show <x> <weekend?>'
      ARGS = {
        number: {
          type: Integer,
          default: nil
        },
        includeWeek: {
          type: Integer,
          default: 0
        }
      }

      def self.exec(context, args)
        args[:includeWeek] = !args[:includeWeek].zero?
        add_str = args[:number] == 1 ? "d'un jour supplémentaire" : "de #{args[:number]} jours supplémentaires"
        waiter = Classes::Waiter.new(context, ":inbox_tray: Affichage #{add_str} sur l'agenda, veuillez patienter...")

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

        waiter.finish("Affichage #{add_str} sur l'agenda effectué.")
      end
    end
  end
end
