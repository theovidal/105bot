module Coronagenda
  module Commands
    def Commands.hide(context, args)
      waiter = context.send_message(':outbox_tray: *Retrait en cours, veuillez patienter...*')
      messages = Models::Messages.reverse(:id).limit(args[0].to_i)
      messages.each do |message|
        $bot.channel($config['server']['output_channel']).message(message[:discord_id]).delete
        message.delete
      end
      waiter.delete
    end
  end
end