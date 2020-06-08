module HundredFive
  module Models
    class Agendas < Sequel::Model
      def self.get(context, error = true)
        agenda = Models::Agendas.where(server: context.server.id, channel: context.channel.id).first
        raise Classes::ExecutionError.new(
          nil,
          "aucun agenda n'a été initialisé dans ce salon. Créez-en un avec la commande #{CONFIG['bot']['prefix']}."
        ) if agenda.nil? && error

        agenda
      end

      def self.get_by_id(agenda)
        Models::Agendas.where(snowflake: agenda).first
      end
    end
  end
end
