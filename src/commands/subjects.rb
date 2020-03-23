require_relative 'command'

module Coronagenda
  module Commands
    class Subjects < Command
      DESCRIPTION = "Obtenir la liste des matières"
      USAGE = "subjects"

      def self.exec(context, args)
        content = ''
        $subjects.each do |id, subject|
          content << ":#{subject['emoji']}: #{subject['name']} : `#{id}`\n"
        end
        context.send_embed('', Discordrb::Webhooks::Embed.new(
          title: 'Liste des matières',
          description: content,
          colour: $config['bot']['color'].to_i
        ))
      end
    end
  end
end
