module HundredFive
  module Commands
    class AboutCommand < Command
      DESC = 'Obtenir les informations pratiques du robot'
      USAGE = 'about'
      LISTEN = %w[private public]

      def self.exec(context, _)
        context.send_embed('', Utils.embed(
          title: ':information_source: À propos',
          description:
            "105bot est un robot Discord offrant la mise en place d'**outils d'organisation** : sessions \"live\" sur Discord, sondages, annotations... Sa fonctionnalité phare est la mise en place d'un agenda collaboratif, c'est-à-dire que quiconque le souhaite peut ajouter des devoies et événements. Le tout est sauvegardé dans un salon du serveur afin d'être consulté rapidement.\n" +
            "Son code source est __ouvert à tous__ : n'hésitez-pas à contribuer à son développement !\n\n" +

            ":hammer: Version : #{CONFIG['meta']['version']}\n" +
            ":bookmark_tabs: [Code source](#{CONFIG['meta']['link']})\n" +
            ":computer: Mainteneur : [Théo Vidal](https://twitter.com/exybore)\n\n" +

            ":copyright: 2021, Théo Vidal. Sous licence [GNU GPL v3](https://github.com/exybore/105bot/blob/master/LICENSE)",
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: CONFIG['meta']['illustration']
          )
        ))
        context.send_embed('', Utils.embed(
          title: ':euro: Faites un don !',
          url: 'https://paypal.me/theovidal2103',
          description: "Si vous aimez le projet, vous pouvez me soutenir en m'offrant un petit café sur PayPal :wink:"
        ))
      end
    end
  end
end
