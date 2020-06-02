require_relative 'command'

module HundredFive
  module Commands
    class Refresh < Command
      DESC = "Rafraichir tout l'agenda visible"
      CATEGORY = 'agenda'
      USAGE = 'refresh'

      def self.exec(context, _)
        waiter = Classes::Waiter.new(context, ":arrows_counterclockwise: Rafraîchissement de l'agenda en cours, veuillez patienter...", "L'exécution de cette commande peut être plus ou moins longue, selon le nombre de jours actuellement affichés.")
        Models::Messages.all.each do |message|
          Models::Messages.refresh(context, message)
        end
        Models::Assignments.refresh_weekly(context)
        waiter.finish("Rafraîchissement de l'agenda effectué.")
      end
    end
  end
end
