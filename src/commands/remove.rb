require_relative 'command'

module Coronagenda
  module Commands
    class Remove < Command
      DESCRIPTION = "Retirer un devoir ou un événement"
      USAGE = "remove <jour> <mois> <type> <numéro>"

      def self.exec(context, args)
        day = args[0]
        month = args[1]
        type = args[2]
        index = args[3].to_i - 1

        context.send_message(':wastebasket: *Suppression du devoir, veuillez patienter...*')
        assignments = Models::Assignments.from_day([day, month]).select{|a| a.type == type}

        assignments[index].delete
        Models::Messages.refresh(context, Models::Messages.from_day([day, month]))
        context.send_message(':white_check_mark: *Devoir supprimé*')
      end
    end
  end
end
