module HundredFive
  module Models
    class Agendas < Sequel::Model
      def self.get(context, waiter, error = true)
        agenda = Models::Agendas.where(server: context.server.id, channel: context.channel.id).first
        raise Classes::ExecutionError.new(
          waiter,
          "aucun agenda n'a été initialisé dans ce salon. Créez-en un avec la commande #{CONFIG['bot']['prefix']}."
        ) if agenda.nil? && error

        return agenda
      end
    end
  end
end
