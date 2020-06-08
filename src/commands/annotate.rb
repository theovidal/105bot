module HundredFive
  module Commands
    class AnnotateCommand < Command
      DESC = 'Annoter une copie envoyée dans un salon textuel'
      LISTEN = %w[private]
      CATEGORY = 'notes'
      ARGS = {
        link: {
          description: 'Lien du message : Clic droit > Copier le lien du message',
          type: String,
          default: nil
        },
        text: {
          description: 'Texte à ajouter à la copie',
          type: String,
          default: nil,
          extend: true
        }
      }

      def self.exec(context, args)
        url = URI(args[:link])
        url_parts = url.path.split('/')

        message_id = url_parts[-1]
        channel_id = url_parts[-2]
        server_id = url_parts[-3]

        raise Classes::ExecutionError.new(nil, "le lien vers le message est incorrect. Vérifiez de l'avoir correctement copié depuis Clic droit > Copier le lien du message") if message_id.nil? || channel_id.nil? || server_id.nil?

        server = context.bot.server(server_id)
        raise Classes::ExecutionError.new(nil, "le serveur Discord est inconnu. Vérifiez d'avoir correctement copié le lien depuis Clic droit > Copier le lien du message") if server.nil?

        channel = context.bot.channel(channel_id)
        raise Classes::ExecutionError.new(nil, "le salon textuel est inconnu. Vérifiez d'avoir correctement copié le lien depuis Clic droit > Copier le lien du message") if channel.nil?

        message = channel.message(message_id)
        raise Classes::ExecutionError.new(nil, "le message source est inconnu. Vérifiez d'avoir correctement copié le lien depuis Clic droit > Copier le lien du message") if message.nil?

        author = server.member(message.author.id)
        annotator = server.member(context.author.id)

        source_files = ''
        message.attachments.each do |file|
          source_files << "#{file.filename} : #{file.url}\n"
        end

        sent_files = ''
        context.message.attachments.each do |file|
          sent_files << "#{file.filename} : #{file.url}\n"
        end

        fields = []
        fields.push(Discordrb::Webhooks::EmbedField.new(
          name: ':card_box: Fichiers source',
          value: source_files
        )) unless source_files == ''
        fields.push(Discordrb::Webhooks::EmbedField.new(
          name: ':dividers: Fichiers joints',
          value: sent_files
        )) unless sent_files == ''

        channel.send_embed('', Utils.embed(
          title: ":memo: Annotation de #{annotator.display_name}",
          description: args[:text],
          author: Discordrb::Webhooks::EmbedAuthor.new(
            icon_url: author.avatar_url,
            name: author.display_name
          ),
          fields: fields
        ))

        context.send_embed('', Utils.embed(
          title: ':warning: Attention',
          description: "Ne supprimez ni votre message, ni celui de la personne ! Si vous le faites, les fichiers ne seront plus accessibles via les liens de l'annotation.",
          color: CONFIG['messages']['error_color']
        ))
      end
    end
  end
end
