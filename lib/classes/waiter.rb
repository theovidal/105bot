module HundredFive
  module Classes
    class Waiter
      attr_reader :text, :msg

      def initialize(context, text, subtext = '')
        @context = context
        @text = text
        @subtext = subtext
        @color = CONFIG['messages']['wait_color']
        @msg = context.send_embed('', generate_msg)
      end

      def edit_subtext(text)
        @subtext = text
        @msg.edit('', generate_msg)
      end

      def finish(text, subtext = '')
        @text = "#{CONFIG['messages']['finished_emoji']} #{text}"
        @subtext = subtext
        @color = CONFIG['messages']['color']
        @msg.edit('', generate_msg)
      end

      def error(text, subtext = '')
        @text = "#{CONFIG['messages']['error_emoji']} #{text}"
        @subtext = subtext
        @color = CONFIG['messages']['error_color']
        @msg.edit('', generate_msg)
      end

      private

      def generate_msg
        Utils.embed(
          description: "**#@text**\n\n#@subtext",
          color: @color
        )
      end
    end
  end
end
