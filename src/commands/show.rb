require_relative 'command'

module Coronagenda
  module Commands
    class Show < Command
      DESCRIPTION = "Montrer l'agenda pour les x jours suivants le dernier message"
      USAGE = 'show <x>'

      def self.exec(context, args)
        context.send_message(':inbox_tray: *Affichage en cours, veuillez patienter...*')

        last = Models::Messages.last
        args[0].to_i.times do |i|
          date = last[:date] + (60 * 60 * 24 * (i + 1))
          discord = context.bot.send_message($config['server']['output_channel'], date)

          model = Models::Messages.create do |message|
            message.date = date
            message.discord_id = discord.id
          end

          Models::Messages.refresh(context, model)
        end

        context.send_message(':white_check_mark: *Affichage terminé*')
      end
    end
  end
end
