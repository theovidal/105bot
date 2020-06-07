module HundredFive
  module Classes
    class Dynamic
      attr_reader :text, :message

      def initialize(context, text, subtext = '')
        @context = context
        @text = text
        @subtext = subtext
        @color = CONFIG['messages']['wait_color']
        @message = context.send_embed('', generate_msg)
      end

      def edit_subtext(text)
        @subtext = text

        save_message
      end

      def finish(text, subtext = '')
        @text = "#{CONFIG['messages']['finished_emoji']} #{text}"
        @subtext = subtext
        @color = CONFIG['messages']['color']

        save_message
      end

      def error(text, subtext = '')
        @text = "#{CONFIG['messages']['error_emoji']} #{text}"
        @subtext = subtext
        @color = CONFIG['messages']['error_color']

        save_message
      end

      private

      def save_message
        @message.edit('', generate_msg)
      end

      def generate_msg
        Utils.embed(
          description: "**#@text**\n\n#@subtext",
          color: @color
        )
      end
    end
  end
end
