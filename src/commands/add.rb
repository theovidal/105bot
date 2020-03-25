require_relative 'command'

module Coronagenda
  module Commands
    class Add < Command
      DESC = "Ajouter un devoir ou un événement. S'il n'y a pas de lien ou d'heure de rendu, préciser `0` dans les champs correspondants."
      USAGE = 'add <jour> <mois> <heure> <matière> <type> <lien> <texte...>'

      def self.parse_args(args)
        {
          day: args[0].to_i,
          month: args[1].to_i,
          hour: args[2].to_i,
          subject: args[3],
          type: args[4],
          link: args[5],
          text: args[6..].join(" ")
        }
      end

      def self.exec(context, args)
        pretty_type = args[:type] == 'homework' ? 'du devoir' : "de l'événement"
        waiter = context.send_embed('', Utils.embed(
          description: ":incoming_envelope: Ajout #{pretty_type} à l'agenda, veuillez patienter..."
        ))

        date = Date.new(2020, args[:month], args[:day])
        Models::Assignments.create do |assignment|
          assignment.date = date
          assignment.hour = args[:hour] if args[:hour] != 0
          assignment.subject = args[:subject]
          assignment.type = args[:type]
          assignment.link = args[:link] if args[:link] != '0'
          assignment.text = args[:text]
        end

        message = Models::Messages.from_day(date)
        Models::Messages.refresh(context, message) if message != nil
        waiter.edit('', Utils.embed(
          description: ":white_check_mark: Ajout #{pretty_type} à l'agenda effectué.\n*Vous ne le voyez pas ? Essayez d'afficher davantage de jours via la commande `a:show` !*"
        ))
      end
    end
  end
end