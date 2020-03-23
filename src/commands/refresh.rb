require_relative 'command'

module Coronagenda
  module Commands
    class Refresh < Command
      DESCRIPTION = "Rafraichir tout l'agenda visible"
      USAGE = 'refresh'

      def self.exec(context, _)
        context.send(":arrows_counterclockwise: *Rafraichissement en cours, veuillez patienter...*
          `L'exécution de cette commande peut être plus ou moins longue, selon le nombre de jours actuellement affichés.`")
        Models::Messages.all.each do |message|
          Models::Messages.refresh(context, message)
        end
        context.send(':white_check_mark: *Rafraichissement terminé*')
      end
    end
  end
end
