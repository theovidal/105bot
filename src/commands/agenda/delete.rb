module HundredFive
  module Commands
    module Agenda
      class DeleteCommand < Command
        DESC = "Supprimer l'agenda dans le salon"
        CATEGORY = 'agenda'
        ARGS = {
          confirm: {
            description: "Confirmer la suppression de l'agenda du salon",
            type: String,
            default: 'no'
          }
        }

        def self.exec(context, args)
          args[:confirm] == 'confirm' ? confirm(context) : advert(context)
        end

        def self.advert(context)
          context.send_embed('', Utils.embed(
            title: ':thinking: Êtes-vous sûrs ?',
            description:
              "Cette commande supprime **définitivement** l'agenda contenu dans ce salon, ainsi que les travaux et événements renseignés dedans.\n" +
              "Si vous êtes sûrs de ce que vous faites, tappez la commande `#{CONFIG['bot']['prefix']}delete confirm`",
            color: CONFIG['messages']['error_color']
          ))
        end

        def self.confirm(context)
          waiter = Classes::Waiter.new(context)

          agenda = Models::Agendas.get(context, waiter)

          messages = Models::Messages.where(agenda: agenda[:snowflake]).all
          Models::Messages.delete_many(context, agenda, messages)

          assignments = Models::Assignments.where(agenda: agenda[:snowflake])
          assignments.each { |assignment| assignment.delete }

          waiter.finish
        end
      end
    end
  end
end
