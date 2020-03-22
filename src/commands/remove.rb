require_relative 'command'

module Coronagenda
  module Commands
    class Remove < Command
      DESCRIPTION = "Retirer un devoir ou un événement"
      USAGE = "remove <jour> <mois> <type> <numéro>"

      def self.exec(context, args)

      end
    end
  end
end
