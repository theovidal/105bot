require_relative 'command'

module HundredFive
  module Commands
    class Hide < Command
      DESC = 'Masquer les x derniers jours affichés'
      CATEGORY = 'agenda'
      ARGS = {
        number: {
          description: 'Nombre de jours à masquer',
          type: Integer,
          default: nil
        }
      }

      def self.exec(context, args)
        last_str = args[:number] == 1 ? 'du dernier jour' : "des #{args[:number]} derniers jours"
        waiter = Classes::Waiter.new(context, ":outbox_tray: Retrait #{last_str} de l'agenda, veuillez patienter...")

        begin
          messages = Models::Messages.reverse(:id).limit(args[:number])
        rescue Sequel::Error
          raise Classes::ExecutionError.new(waiter, "le nombre #{args[:number]} est incorrect.")
        end

        messages.each do |message|
          context.bot.channel(CONFIG['server']['output_channel']).message(message[:discord_id]).delete
          message.delete
        end

        waiter.finish("Retrait #{last_str} de l'agenda effectué.")
      end
    end
  end
end
