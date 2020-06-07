module HundredFive
  module Commands
    class Help < Command
      DESC = "Obtenir de l'aide sur l'utilisation du robot"
      LISTEN = %w[private public]

      def self.exec(context, _)
        context.author.pm.send_embed('', Utils.embed(
          title: ':question: Comment ça marche ?',
          description: "Pour demander au robot de faire certaines actions, il faut exécuter des **commandes** dont la liste est située ci-dessous.\n" \
                  "Certaines commandes possèdent des **arguments** afin de leur préciser des détails, comme une date ou un texte.\n" \
                  "Ces arguments doivent être placés __séparés par une virgule__. Si une valeur par défaut existe, celui-ci peut être laissé vide.\n" \
                  "\n" \
                  "*Exemple : `a:add 27,03,0,Italien,work,https://urlz.fr/cdvu,Faire les deux exercices de la pièce jointe (lien). Pas obligé de renvoyer.\n`" \
                  "--> Ajoute un travail en italien pour le 27 mars sans date de rendu, avec un lien et un texte.*",
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: 'https://cdn4.iconfinder.com/data/icons/school-subjects/256/Informatics-512.png'
          )
        ))
        context.message.react('✅')
      end
    end
  end
end
