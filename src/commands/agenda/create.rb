module HundredFive
  module Commands
    class Create < Command
      DESC = 'Créer un agenda dans le salon'
      CATEGORY = 'agenda'
      ARGS = {
        name: {
          description: 'Nom de votre agenda',
          type: String,
          default: 'Agenda',
          extends: true
        }
      }

      def self.exec(context, args)
        waiter = Classes::Waiter.new(context)

        agenda = Models::Agendas.get(context, waiter, false)
        raise Classes::ExecutionError.new(waiter, 'un agenda existe déjà dans ce salon.') unless agenda.nil?

        snowflake = ::SF.next
        Models::Agendas.create do |agenda|
          agenda.name = args[:name]
          agenda.snowflake = snowflake
          agenda.server = context.server.id
          agenda.channel = context.channel.id
        end

        message = context.send("--- GÉNÉRATION DE L'AGENDA ---")
        Models::Messages.create do |model|
          model.agenda = snowflake
          model.message = message.id
          model.weekly = true
        end
        message.pin

        waiter.finish
      end
    end
  end
end
