module HundredFive
  module Commands
    class Show < Command
      DESC = "Montrer l'agenda pour les x jours suivants le dernier message"
      CATEGORY = 'agenda'
      ARGS = {
        number: {
          description: 'Nombre de jours à afficher',
          type: Integer,
          default: nil
        },
        includeWeek: {
          description: 'Inclure ou non les jours de week-end (Samedi et Dimanche)',
          type: Integer,
          boolean: true,
          default: 0
        }
      }

      def self.exec(context, args)
        waiter = Classes::Waiter.new(context)

        agenda = Models::Agendas.get(context, waiter)

        last = Models::Messages.from_agenda(agenda[:snowflake]).last
        start = last.nil? ? Date.today : last[:date]
        day_delay = 0

        args[:number].to_i.times do |i|
          date = start + i + day_delay + 1
          if date.wday == 0 || date.wday == 6
            day_delay += 1
            redo
          end
          output = context.send("--- GÉNÉRATION DU MESSAGE DE L'AGENDA ---")

          model = Models::Messages.create do |message|
            message.agenda = agenda.snowflake
            message.message = output.id
            message.date = date
          end

          Models::Messages.refresh(context, agenda, model)
        end

        waiter.finish
      end
    end
  end
end
