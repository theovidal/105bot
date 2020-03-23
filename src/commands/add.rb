require_relative 'command'

module Coronagenda
  module Commands
    class Add < Command
      DESCRIPTION = "Ajouter un devoir ou un événement. S'il n'y a pas de lien ou d'heure de rendu, préciser `0` dans les champs correspondants."
      USAGE = 'add <jour> <mois> <heure> <matière> <type> <lien> <texte...>'

      def self.exec(context, args)
        context.send_message(":incoming_envelope: *Ajout du devoir/événement, veuillez patienter...*")

        day = args[0]
        month = args[1]
        hour = args[2]
        subject = args[3]
        type = args[4]
        link = args[5]
        text = args[6..].join(" ")

        date = Time.new(2020, month, day, hour)
        Models::Assignments.create do |assignment|
          assignment.date = date
          assignment.to_give = hour.to_i == 0
          assignment.subject = subject
          assignment.type = type
          assignment.link = link if link != '0'
          assignment.text = text
        end

        Models::Messages.refresh(context, Models::Messages.from_day([day, month]))
        context.send_message(":white_check_mark: *Devoir/Événement ajouté à l'agenda.*
          `Vous ne le voyez pas ? Essayez d'afficher davantage de jours via la commande show !`")
      end
    end
  end
end