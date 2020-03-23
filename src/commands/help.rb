require_relative 'command'

module Coronagenda
  module Commands
    class Help < Command
      DESC = "Obtenir de l'aide sur le robot"
      USAGE = 'help'

      def self.exec(context, _args)
        content = ''
        $bot.commands.each do |_index, command|
          content << "#{command.to_s}\n"
        end
        context.send_embed('', Utils.embed(
          title: 'Liste des commandes',
          description: content,
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: 'https://cdn4.iconfinder.com/data/icons/school-subjects/256/Literature-512.png'
          )
        ))
      end
    end
  end
end
