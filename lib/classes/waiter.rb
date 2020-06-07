module HundredFive
  module Classes
    class Waiter
      attr_reader :message

      def initialize(context, set_wait = true)
        @context = context
        @message = context.message
        wait if set_wait
      end

      def action_needed
        set_reaction('📬')
      end

      def wait
        set_reaction('🔄')
      end

      def finish
        set_reaction('✅')
        delete_message
      end

      def error(text, subtext = nil)
        set_reaction('❌')

        @context.author.pm.send_embed('', Utils.embed(
          description: "**#{text}**\n\n#{subtext}",
          color: CONFIG['messages']['error_color']
        ))
      end

      private

      def set_reaction(emoji)
        @message.delete_all_reactions unless @context.channel.private?
        @message.react(emoji)
      end

      def delete_message
        unless @context.channel.private?
          sleep(3)
          @message.delete
        end
      end
    end
  end
end
