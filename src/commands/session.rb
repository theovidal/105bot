require_relative 'command'

module HundredFive
  module Commands
    class Session < Command
      DESC = 'Démarrer une session de participation sur Discord'
      CATEGORY = 'notes'

      def self.exec(context, _)
        context.message.delete
        waiter = Classes::Waiter.new(context, ":microphone2: Session en cours par #{context.user.nick}", "Réagissez à ce message avec l'émoticone :raising_hand: pour demander la parole. Le gérant de la session peut l'arrêter en réagissant avec l'émoticone :stop_sign:.")
        waiter.msg.react('🙋')
        waiter.msg.react('🔊')
        waiter.msg.react('🛑')
        waiter.msg.pin()

        tts = false
        loop do
          event = context.bot.add_await!(Discordrb::Events::ReactionAddEvent)
          next unless event.channel.id == context.channel.id
          is_host = event.user.id == context.user.id
          case event.emoji.name
          when '🙋'
            context.send("#{context.user.mention} Participation demandée par #{event.user.mention}", tts)
          when '🔊'
            if is_host
              tts = !tts
              emoji = tts ? ':loud_sound:' : ':mute:'
              state = tts ? 'activé' : 'désactivé'
              context.send("#{emoji} #{context.user.mention} Son #{state} pour les demandes de participation.")
            else
              event.user.pm.send_message(":x: **Vous ne pouvez pas modifier le son de la session, car vous n'en êtes pas le propriétaire.**")
            end
          when '🛑'
            if is_host
              waiter.msg.unpin()
              waiter.finish(":door: La session avec #{context.user.nick} est désormais terminée.")
              break
            else
              event.user.pm.send_message(":x: **Vous ne pouvez pas fermer la session de #{context.user.nick}, car vous n'en êtes pas le propriétaire.**")
            end
          else
            event.user.pm.send_message(":question: Réaction inconnue. Merci de réagir à l'aide de celles déjà disponibles.")
          end
          waiter.msg.delete_reaction(event.user, event.emoji.name)
        end
      end
    end
  end
end
