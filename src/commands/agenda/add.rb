module HundredFive
  module Commands
    module Agenda
      class AddCommand < Command
        DESC = "Ajouter un devoir ou un événement. S'il n'y a pas de lien ou d'heure de rendu, préciser `0` dans les champs correspondants."
        CATEGORY = 'agenda'
        ARGS = {
          day: {
            description: 'Jour de la tâche',
            type: Integer,
            default: nil
          },
          month: {
            description: 'Mois de la tâche',
            type: Integer,
            default: Date.today.month
          },
          hour: {
            description: "Heure de l'événement / Heure de rendu du devoir s'il y en a une",
            type: Integer,
            default: 0
          },
          type: {
            description: 'Type de la tâche : `work` pour un tavail ou devoir; `event` pour un événement; `weekly_event` pour un événement hebdomadaire',
            type: String,
            default: 'work'
          },
          subject: {
            description: 'Sujet de la tâche',
            type: String,
            default: '0'
          },
          link: {
            description: "Lien associé à la tâche (laisser vide s'il n'y en a pas)",
            type: String,
            default: '0'
          },
          text: {
            description: 'Description de la tâche',
            type: String,
            default: nil,
            extend: true
          }
        }

        def self.exec(context, args)
          waiter = Classes::Waiter.new(context)

          raise Classes::ExecutionError.new(waiter, "le type `#{args[:type]}` est inconnu.") unless Models::Assignments::TYPES.include? args[:type]

          begin
            date = Date.new(2020, args[:month], args[:day])
          rescue ArgumentError
            raise Classes::ExecutionError.new(waiter, 'la date est incorrecte.')
          end

          agenda = Models::Agendas.get(context, waiter)

          Models::Assignments.create do |assignment|
            assignment.agenda = agenda[:snowflake]
            assignment.type = args[:type] == 'weekly_event' ? 'event' : args[:type]
            assignment.subject = args[:subject] if args[:subject] != '0'
            assignment.text = args[:text]
            assignment.link = args[:link] if args[:link] != '0'
            assignment.date = date
            assignment.hour = args[:hour] if args[:hour] != 0
            assignment.is_weekly = args[:type] == 'weekly_event'
          end

          message = Models::Messages.from_day(agenda[:snowflake], date)
          Models::Messages.refresh(context, agenda, message) if message != nil
          Models::Messages.refresh_weekly(context, agenda[:snowflake]) if args[:type] == 'weekly_event'

          waiter.finish
        end
      end
    end
  end
end
