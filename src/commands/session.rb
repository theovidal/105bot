require_relative 'command'

module HundredFive
  module Commands
    class Session < Command
      DESC = 'Démarrer une session de participation sur Discord'
      CATEGORY = 'notes'

      def self.exec(context, _)
        waiter = Classes::Waiter.new(context, ":microphone2: Session en cours par #{context.user.nick}", "Réagissez à ce message avec l'émoticone :raising_hand: pour demander la parole. Le gérant de la session peut l'arrêter en réagissant avec l'émoticone :stop_sign:.")
        waiter.msg.pin()
        waiter.msg.react('🙋')
        waiter.msg.react('🛑')
        loop do
          event = context.bot.add_await!(Discordrb::Events::ReactionAddEvent)
          next unless event.channel.id == context.channel.id
          if event.emoji.name == '🙋'
            context.send("🙋 #{context.user.mention} Participation demandée par #{event.user.mention}")
          elsif event.emoji.name == '🛑' && event.user.id == context.user.id
            waiter.msg.unpin()
            waiter.finish(":door: La session avec #{context.user.nick} est désormais terminée.")
            break
          end
          waiter.msg.delete_reaction(event.user, event.emoji.name)
        end
      end
    end
  end
end