module Coronagenda
  module Commands
    def Commands.refresh
      Models::Messages.all.each do |message|
        content = ''
        content << Models::Messages.prettify(message)

        assignments = Models::Assignments.all.select do |a|
          a[:date] > message[:date] && a.date <= message[:date] + 86400
        end

        homework = ''
        events = ''

        assignments.each do |assignment|
          if assignment[:type] == 'homework'
            homework << Models::Assignments.prettify(assignment)
          else
            events << Models::Assignments.prettify(assignment)
          end
        end

        events = "Aucun événement n'est prévu pour ce jour\n" if events == ''
        homework = "Aucun devoir n'est à rendre pour ce jour" if homework == ''

        content << "__:incoming_envelope: Événements :__\n#{events}\n"
        content << "__:clipboard: Devoirs :__\n#{homework}"

        $bot.channel($config['server']['output_channel']).message(message[:discord_id]).edit(content)
      end
    end
  end
end