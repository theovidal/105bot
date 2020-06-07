module HundredFive
  module Commands
    class Commands < Command
      DESC = 'Obtenir la liste des commandes disponibles sur le robot'
      LISTEN = %w[private public]

      def self.exec(context, _)
        command_categories = {}
        CATEGORIES.each_key do |category|
          command_categories[category] = ''
        end

        $bot.commands.each do |_index, command|
          command_categories[command.category] << "#{command.to_s}\n"
        end

        command_categories.each do |category, commands|
          next if commands == ''
          context.author.pm.send_embed('', Utils.embed(
            title: ":#{CATEGORIES[category]['emoji']}: #{CATEGORIES[category]['name']}",
            description: commands
          ))
        end

        context.message.react('✅')
      end
    end
  end
end
