require_relative 'command'

module HundredFive
  module Commands
    class Help < Command
      DESC = "Obtenir de l'aide sur le robot (utilisation, commandes, matières...)"

      def self.exec(context, _args)
        context.send_embed('', Utils.embed(
          title: ':question: Comment ça marche ?',
          description: "Pour demander au robot de faire certaines actions, il faut exécuter des **commandes** dont la liste est située ci-dessous.\n" \
                  "Certaines commandes possèdent des **arguments** afin de leur préciser des détails, comme une date ou un texte.\n" \
                  "Ces arguments doivent être placés __séparés par une virgule__. Si une valeur par défaut existe, celui-ci peut être laissé vide.\n" \
                  "\n" \
                  "*Exemple : `a:add 27,03,0,italian,homework,https://urlz.fr/cdvu,Faire les deux exercices de la pièce jointe (lien). Pas obligé de renvoyer.\n`" \
                  "--> Ajoute un devoir en italien pour le 27 mars sans date de rendu, avec un lien et un texte.*",
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: 'https://cdn4.iconfinder.com/data/icons/school-subjects/256/Informatics-512.png'
          )
        ))

        commands = ''
        $bot.commands.each do |_index, command|
          commands << "#{command.to_s}\n"
        end
        context.send_embed('', Utils.embed(
          title: ':fast_forward: Liste des commandes',
          description: commands,
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: 'https://cdn4.iconfinder.com/data/icons/school-subjects/256/Literature-512.png'
          )
        ))

        subjects = ''
        SUBJECTS.each do |id, subject|
          subjects << "#{subject['emoji']} #{subject['name']} : `#{id}`\n"
        end
        context.send_embed('', Utils.embed(
          title: ':fast_forward: Liste des matières',
          description: subjects,
          thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
            url: 'https://cdn4.iconfinder.com/data/icons/school-subjects/256/Geography-128.png'
          )
        ))
      end
    end
  end
end
