require_relative 'command'

module Coronagenda
  module Commands
    class Remove < Command
      DESCRIPTION = "Retirer un devoir ou un événement"
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
        context.send_message(':wastebasket: *Suppression du devoir, veuillez patienter...*')
        assignments =
          Models::Assignments.from_day([args[:day], args[:month]]).select{|a| a.type == args[:type]}

        assignments[args[:index]].delete
        Models::Messages.refresh(context, Models::Messages.from_day([args[:day], args[:month]]))
        context.send_message(':white_check_mark: *Devoir supprimé*')
      end
    end
  end
end
