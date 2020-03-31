require_relative 'command'

module HundredFive
  module Commands
    class Remove < Command
      DESC = 'Retirer un devoir ou un événement'
      ARGS = {
        day: {
          description: 'Jour de la tâche (laisser vide pour un événement hebdomadaire)',
          type: Integer,
          default: Date.today.day
        },
        month: {
          description: 'Mois de la tâche (laisser vide pour un événement hebdomadaire)',
          type: Integer,
          default: Date.today.month
        },
        type: {
          description: 'Type de la tâche : `homework` pour un devoir; `event` pour un événement; `weekly_event` pour un événement hebdomadaire',
          type: String,
          default: 'homework'
        },
        index: {
          description: 'Numéro de la tâche dans la liste',
          type: Integer,
          default: 1
        }
      }

      def self.exec(context, args)
        args[:index] -= 1

        pretty_type = args[:type] == 'homework' ? 'du devoir' : "de l'événement"
        waiter = Classes::Waiter.new(context, ":wastebasket: Suppression #{pretty_type} de l'agenda, veuillez patienter...")

        raise Classes::ExecutionError.new(waiter, "le type `#{args[:type]}` est inconnu.") unless Models::Assignments::TYPES.include? args[:type]

        begin
          date = Date.new(2020, args[:month], args[:day])
        rescue ArgumentError
          raise Classes::ExecutionError.new(waiter, 'la date est incorrecte.')
        end

        is_weekly = args[:type] == 'weekly_event'
        assignments = is_weekly ? Models::Assignments.where(is_weekly: true).all : Models::Assignments.from_day(date).select{ |a| a.type == args[:type] }

        assignment = assignments[args[:index]]
        raise Classes::ExecutionError.new(waiter, "le numéro #{pretty_type} est incorrect.") if assignment.nil?

        assignment.delete
        if is_weekly
          Models::Assignments.refresh_weekly(context)
        else
          message = Models::Messages.from_day(date)
          Models::Messages.refresh(context, message) if message != nil
        end

        waiter.finish("Suppression #{pretty_type} de l'agenda effectué.")
      end
    end
  end
end
