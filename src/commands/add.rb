require_relative 'command'

module Coronagenda
  module Commands
    class Add < Command
      DESC = "Ajouter un devoir ou un événement. S'il n'y a pas de lien ou d'heure de rendu, préciser `0` dans les champs correspondants."
      USAGE = 'add <jour> <mois> <heure> <matière> <type> <lien> <texte...>'
      ARGS = {
        day: {
          type: Integer,
          default: nil
        },
        month: {
          type: Integer,
          default: Date.today.month
        },
        hour: {
          type: Integer,
          default: 0
        },
        subject: {
          type: String,
          default: nil
        },
        type: {
          type: String,
          default: 'homework'
        },
        link: {
          type: String,
          default: '0'
        },
        text: {
          type: String,
          default: nil,
          extend: true
        }
      }

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