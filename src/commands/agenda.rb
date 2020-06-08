module HundredFive
  module Commands
    class AgendaCommand < Command
      DESC = 'Gérez un agenda sur Discord'
      LISTEN = %w[public private]
      SUBCOMMANDS = true

      def self.exec(context, _)
        context.message.delete unless context.channel.private?
        context.author.pm.send_embed('', Utils.embed(
          description: "**#{CONFIG['messages']['error_emoji']} Merci de préciser une sous-commande.**",
          color: CONFIG['messages']['error_color']
        ))
      end
    end
  end
end