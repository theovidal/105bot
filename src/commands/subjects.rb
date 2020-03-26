require_relative 'command'

module Coronagenda
  module Commands
    class Subjects < Command
      DESC = "Obtenir la liste des matières"
      USAGE = "subjects"

      def self.exec(context, _)
        content = ''
        SUBJECTS.each do |id, subject|
          content << ":#{subject['emoji']}: #{subject['name']} : `#{id}`\n"
        end
        context.send_embed('', Utils.embed(
          title: 'Liste des matières',
          description: content,
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: 'https://cdn4.iconfinder.com/data/icons/school-subjects/256/Geography-128.png'
          )
        ))
      end
    end
  end
end
