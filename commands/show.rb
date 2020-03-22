module Coronagenda
  module Commands
    def Commands.show(args)
      waiter = $bot.send_message(690904527423012873, ':inbox_tray: *Affichage en cours, veuillez patienter...*')

      last = Models::Messages.last
      args[0].to_i.times do |i|
        date = last[:date] + (60 * 60 * 24 * (i + 1))
        discord = $bot.send_message(690904527423012873, date)

        Models::Messages.create do |message|
          message.date = date
          message.discord_id = discord.id
        end
      end

      Commands::refresh

      waiter.delete
    end
  end
end