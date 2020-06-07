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
        waiter = Classes::Waiter.new(context)

        agenda = Models::Agendas.get(context, waiter)

        begin
          messages = Models::Messages.from_agenda(agenda[:snowflake]).reverse(:id).limit(args[:number]).all
        rescue Sequel::Error
          raise Classes::ExecutionError.new(waiter, "le nombre #{args[:number]} est incorrect.")
        end

        Models::Messages.delete_many(context, agenda, messages)

        waiter.finish
      end
    end
  end
end
