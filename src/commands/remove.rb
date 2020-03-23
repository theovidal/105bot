require_relative 'command'

module Coronagenda
  module Commands
    class Remove < Command
      DESC = "Retirer un devoir ou un événement"
      USAGE = "remove <jour> <mois> <type> <numéro>"

      def self.parse_args(args)
        {
          day: args[0],
          month: args[1],
          type: args[2],
          index: args[3].to_i - 1
        }
      end

      def self.exec(context, args)
        pretty_type = args[:type] == 'homework' ? 'du devoir' : "de l'événement"
        waiter = context.send_embed('', Utils.embed(
          description: ":wastebasket: Suppression #{pretty_type} de l'agenda, veuillez patienter..."
        ))

        assignments =
          Models::Assignments.from_day([args[:day], args[:month]]).select{|a| a.type == args[:type]}
        assignments[args[:index]].delete
        Models::Messages.refresh(context, Models::Messages.from_day([args[:day], args[:month]]))

        waiter.edit('', Utils.embed(
          description: ":white_check_mark: Suppression #{pretty_type} de l'agenda effectué."
        ))
      end
    end
  end
end
