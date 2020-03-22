require_relative 'command'

module Coronagenda
  module Commands
    class Add < Command
      DESCRIPTION = "Ajouter un devoir ou un événement. S'il n'y a pas de lien, préciser `0`"
      USAGE = 'add <jour> <mois> <heure> <matière> <type> <lien> <texte...>'

      def self.exec(context, args)
        context.send_message(":incoming_envelope: *Ajout du devoir/événement, veuillez patienter...*")

        date = Time.new(2020, args[1], args[0], args[2])
        Models::Assignments.create do |assignment|
          assignment.date = date
          assignment.subject = args[3]
          assignment.type = args[4]
          assignment.link = args[5]
          assignment.text = args[6..].join(" ")
        end

        Commands::Refresh.exec(context, nil)
        context.send_message(":white_check_mark: *Devoir/Événement ajouté à l'agenda.*
          `Vous ne le voyez pas ? Essayez d'afficher davantage de jours via la commande show !`")
      end
    end
  end
end