require_relative 'command'

module Coronagenda
  module Commands
    class Remove < Command
      DESC = "Retirer un devoir ou un événement"
      USAGE = "remove <jour> <mois> <type> <numéro>"
      ARGS = {
        day: {
          type: Integer,
          default: Date.today.day
        },
        month: {
          type: Integer,
          default: Date.today.month
        },
        type: {
          type: String,
          default: 'homework'
        },
        index: {
          type: Integer,
          default: 1
        }
      }

      def self.exec(context, args)
        args[:index] -= 1

        pretty_type = args[:type] == 'homework' ? 'du devoir' : "de l'événement"
        waiter = context.send_embed('', Utils.embed(
          description: ":wastebasket: Suppression #{pretty_type} de l'agenda, veuillez patienter..."
        ))

        date = Date.new(2020, args[:month], args[:day])

        assignments =
          Models::Assignments.from_day(date).select{|a| a.type == args[:type]}
        assignments[args[:index]].delete

        message = Models::Messages.from_day(date)
        Models::Messages.refresh(context, message) if message != nil

        waiter.edit('', Utils.embed(
          description: ":white_check_mark: Suppression #{pretty_type} de l'agenda effectué."
        ))
      end
    end
  end
end
