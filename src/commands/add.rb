require_relative 'command'

module Coronagenda
  module Commands
    class Add < Command
      DESCRIPTION = "Ajouter un devoir ou un événement. S'il n'y a pas de lien ou d'heure de rendu, préciser `0` dans les champs correspondants."
      USAGE = 'add <jour> <mois> <heure> <matière> <type> <lien> <texte...>'

      def self.parse_args(args)
        {
          day: args[0],
          month: args[1],
          hour: args[2],
          subject: args[3],
          type: args[4],
          link: args[5],
          text: args[6..].join(" ")
        }
      end

      def self.exec(context, args)
        context.send_message(":incoming_envelope: *Ajout du devoir/événement, veuillez patienter...*")

        date = Time.new(2020, args[:month], args[:day], args[:hour])
        Models::Assignments.create do |assignment|
          assignment.date = date
          assignment.to_give = args[:hour].to_i == 0
          assignment.subject = args[:subject]
          assignment.type = args[:type]
          assignment.link = args[:link] if args[:link] != '0'
          assignment.text = args[:text]
        end

        Models::Messages.refresh(context, Models::Messages.from_day([args[:day], args[:month]]))
        context.send_message(":white_check_mark: *Devoir/Événement ajouté à l'agenda.*
          `Vous ne le voyez pas ? Essayez d'afficher davantage de jours via la commande show !`")
      end
    end
  end
end