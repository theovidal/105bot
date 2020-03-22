module Coronagenda
  module Commands
    def Commands.show(context, args)
      waiter = context.send_message(':inbox_tray: *Affichage en cours, veuillez patienter...*')

      last = Models::Messages.last
      args[0].to_i.times do |i|
        date = last[:date] + (60 * 60 * 24 * (i + 1))
        discord = $bot.send_message($config['server']['output_channel'], date)

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