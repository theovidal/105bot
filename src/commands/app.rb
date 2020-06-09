module HundredFive
  module Commands
    class AppCommand < Command
      DESC = 'Obtenir le lien vers 105app, le site pratique pour réviser ses cours'

      def self.exec(context, _)
        context.send_embed('', Utils.embed(
          title: '105app — Les fiches de révision pratiques',
          url: 'https://105app.exybo.re',
          description:
            "105app est un site Internet qui met à disposition des fiches de révision pratiques et allant à l'essentiel. Elles sont éditées personnellement par Théo Vidal et concernent la voie générale du lycée.\n\n" +
            "[Consultez 105app](https://105app.exybo.re) dès maintenant, ou [explorez son code source](https://github.com/exybore/105app) ! :wink:",
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: 'https://105app.exybo.re/img/icons/icon-512x512.png'
          )
        ))
      end
    end
  end
end
