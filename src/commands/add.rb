require_relative 'command'

module HundredFive
  module Commands
    class Add < Command
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
        subject: {
          description: 'Matière concernée par la tâche',
          type: String,
          default: nil
        },
        type: {
          description: 'Type de la tâche : `homework` pour un devoir; `event` pour un événement; `weekly_event` pour un événement hebdomadaire',
          type: String,
          default: 'homework'
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
        pretty_type = args[:type] == 'homework' ? 'du devoir' : "de l'événement"
        waiter = Classes::Waiter.new(context, ":incoming_envelope: Ajout #{pretty_type} à l'agenda, veuillez patienter...")

        raise Classes::ExecutionError.new(waiter, "le type `#{args[:type]}` est inconnu.") unless Models::Assignments::TYPES.include? args[:type]
        raise Classes::ExecutionError.new(waiter, "la matière `#{args[:subject]}` est inconnue.") unless SUBJECTS.include? args[:subject]

        begin
          date = Date.new(2020, args[:month], args[:day])
        rescue ArgumentError
          raise Classes::ExecutionError.new(waiter, 'la date est incorrecte.')
        end

        Models::Assignments.create do |assignment|
          assignment.date = date
          assignment.hour = args[:hour] if args[:hour] != 0
          assignment.subject = args[:subject]
          assignment.type = args[:type] == 'weekly_event' ? 'event' : args[:type]
          assignment.link = args[:link] if args[:link] != '0'
          assignment.text = args[:text]
          assignment.is_weekly = args[:type] == 'weekly_event'
        end

        message = Models::Messages.from_day(date)
        Models::Messages.refresh(context, message) if message != nil
        Models::Assignments.refresh_weekly(context) if args[:type] == 'weekly_event'

        waiter.finish("Ajout #{pretty_type} à l'agenda effectué.", "Vous ne le voyez pas ? Essayez d'afficher davantage de jours via la commande `#{CONFIG['bot']['prefix']}show` !")
      end
    end
  end
end