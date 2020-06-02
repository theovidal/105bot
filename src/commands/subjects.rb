require_relative 'command'

module HundredFive
  module Commands
    class Subjects < Command
      DESC = "Obtenir la liste des matières disponibles sur l'agenda"
      LISTEN = %w(private public)
      CATEGORY = 'agenda'

      def self.exec(context, _args)
        subjects = ''
        SUBJECTS.each do |id, subject|
          subjects << "#{subject['emoji']} #{subject['name']} : `#{id}`\n"
        end
        context.author.pm.send_embed('', Utils.embed(
          title: ':fast_forward: Liste des matières',
          description: subjects,
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: 'https://cdn4.iconfinder.com/data/icons/school-subjects/256/Geography-128.png'
          )
        ))
        context.message.react('✅')
      end
    end
  end
end
