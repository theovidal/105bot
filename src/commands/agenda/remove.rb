module HundredFive
  module Commands
    class Remove < Command
      DESC = 'Retirer un devoir ou un événement'
      CATEGORY = 'agenda'
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
          description: 'Type de la tâche : `work` pour un travail; `event` pour un événement; `weekly_event` pour un événement hebdomadaire',
          type: String,
          default: 'work'
        },
        index: {
          description: 'Numéro de la tâche dans la liste',
          type: Integer,
          default: 1
        }
      }

      def self.exec(context, args)
        args[:index] -= 1

        pretty_type = args[:type] == 'work' ? 'du devoir' : "de l'événement"
        waiter = Classes::Waiter.new(context)

        raise Classes::ExecutionError.new(waiter, "le type `#{args[:type]}` est inconnu.") unless Models::Assignments::TYPES.include? args[:type]

        begin
          date = Date.new(2020, args[:month], args[:day])
        rescue ArgumentError
          raise Classes::ExecutionError.new(waiter, 'la date est incorrecte.')
        end

        agenda = Models::Agendas.get(context, waiter)

        is_weekly = args[:type] == 'weekly_event'
        assignments = Models::Assignments.where(agenda: agenda[:snowflake])
        assignments =
          is_weekly ? assignments.where(is_weekly: true).all
          : Models::Assignments.from_day(agenda[:snowflake], date).select{ |a| a[:type] == args[:type] }

        assignment = assignments[args[:index]]
        raise Classes::ExecutionError.new(waiter, "le numéro #{pretty_type} est incorrect.") if assignment.nil?

        assignment.delete
        if is_weekly
          Models::Messages.refresh_weekly(context, agenda)
        else
          message = Models::Messages.from_day(agenda[:snowflake], date)
          Models::Messages.refresh(context, agenda, message) if message != nil
        end

        waiter.finish
      end
    end
  end
end
