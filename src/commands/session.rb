module HundredFive
  module Commands
    class SessionCommand < Command
      DESC = 'Démarrer une session de participation sur Discord'
      CATEGORY = 'notes'

      INTERACTIONS = %w(🙋 🔊 📑 🛑)
      REACTIONS = %w(✅ ❌ 🙂 🤔 🙁 😮)

      def self.exec(context, _)
        context.message.delete
        dynamic = Classes::Dynamic.new(context, ":microphone2: Session en cours par #{context.user.display_name}", "Préparation de la session, veuillez patienter...")
        (REACTIONS + INTERACTIONS).each { |interaction| dynamic.message.react(interaction) }
        dynamic.message.pin()

        dynamic.edit_subtext("Demandez la parole avec l'émoticône :raising_hand: ou réagissez avec les autres. Le gérant de la session peut l'arrêter en réagissant avec l'émoticone :stop_sign:.")
        tts = false
        loop do
          event = context.bot.add_await!(Discordrb::Events::ReactionAddEvent, {
            timeout: 60 * 60 * 12
          })
          if event.nil?
            dynamic.error(":door: La session de #{context.user.display_name} a expiré.")
            dynamic.message.unpin()
            break
          end
          next unless event.channel.id == context.channel.id

          is_host = event.user.id == context.user.id
          reaction = event.emoji.name

          case reaction
          when '🙋'
            context.send("#{context.user.mention} Participation demandée par #{event.user.mention}", tts)
          when '📑'
            fields = []
            message = context.channel.message(dynamic.message.id)
            message.reactions.each do |emoji, object|
              next unless REACTIONS.include? emoji
              next if object.count < 2

              reactors = message.reacted_with(emoji).collect { |u| context.server.member(u.id).display_name }
              fields << Discordrb::Webhooks::EmbedField.new(
                name: "#{emoji} : #{object.count - 1}",
                value: reactors.join(', ').chomp(', ')
              )
            end
            event.user.pm.send_embed('', Utils.embed(
              title: "📑 Bilan des réactions",
              fields: fields,
              author: Discordrb::Webhooks::EmbedAuthor.new(
                icon_url: context.user.avatar_url,
                name: context.user.display_name
              )
            ))
          when '🔊'
            if is_host
              tts = !tts
              emoji = tts ? ':loud_sound:' : ':mute:'
              state = tts ? 'activé' : 'désactivé'
              context.user.pm.send_message("#{emoji} Son **#{state}** pour les demandes de participation.")
            else
              event.user.pm.send_message(":x: **Vous ne pouvez pas modifier le son de la session, car vous n'en êtes pas le propriétaire. Contactez l'hôte pour faire une demande à ce propos.**")
            end
          when '🛑'
            if is_host
              dynamic.message.unpin()
              dynamic.finish(":door: La session avec #{context.user.display_name} est désormais terminée.")
              break
            else
              event.user.pm.send_message(":x: **Vous ne pouvez pas fermer la session de #{context.user.display_name}, car vous n'en êtes pas le propriétaire. Contactez l'hôte pour faire une demande à ce propos.**")
            end
          else
            next if REACTIONS.include? reaction
            event.user.pm.send_message(":question: Réaction inconnue. Merci de réagir à l'aide de celles déjà disponibles.")
          end
          dynamic.message.delete_reaction(event.user, event.emoji.name)
        end
      end
    end
  end
end
