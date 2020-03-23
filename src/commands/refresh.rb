require_relative 'command'

module Coronagenda
  module Commands
    class Refresh < Command
      DESC = "Rafraichir tout l'agenda visible"
      USAGE = 'refresh'

      def self.exec(context, _)
        waiter = context.send_embed('', Utils.embed(
          description: ":arrows_counterclockwise: Rafraîchissement de l'agenda en cours, veuillez patienter...\n*L'exécution de cette commande peut être plus ou moins longue, selon le nombre de jours actuellement affichés.*"
        ))
        Models::Messages.all.each do |message|
          Models::Messages.refresh(context, message)
        end
        waiter.edit('', Utils.embed(
          description: ":white_check_mark: Rafraîchissement de l'agenda effectué."
        ))
      end
    end
  end
end
