module HundredFive
  module Commands
    module Agenda
      class CreateCommand < Command
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
          agenda = Models::Agendas.get(context, false)
          raise Classes::ExecutionError.new(nil, 'un agenda existe déjà dans ce salon.') unless agenda.nil?

          waiter = Classes::Waiter.new(context)

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
          Models::Messages.refresh_weekly(context, snowflake)
          message.pin

          waiter.finish
        end
      end
    end
  end
end
