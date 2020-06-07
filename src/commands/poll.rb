require_relative 'command'

module HundredFive
  module Commands
    class Poll < Command
      DESC = 'Lancer un sondage grâce aux réactions de Discord'
      CATEGORY = 'notes'
      ARGS = {
        name: {
          description: 'Nom du sondage',
          type: String,
          default: nil,
        },
        type: {
          description: "Thème pour les réactions. Valeur possibles : shapes, numbers, letters, food, faces, transportation",
          type: String,
          default: 'shapes'
        },
        options: {
          description: 'Options du sondage, séparées par une virgule (20 maximum)',
          type: String,
          default: nil,
          extend: true
        }
      }

      OPTIONS = {
        'shapes'         => %w[🔴 🟤 🟠 🟣 🟡 🔵 🟢 ⚫ ⚪ 🟥 🟫 🟧 🟪 🟨 🟦 🟩 ⬛ ⬜ 🔶 🔺],
        'numbers'        => %w[0️⃣ 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣ 8️⃣ 9️⃣ 🔟 🇦 🇧 🇨 🇩 🇪 🇫 🇬 🇭 🇮],
        'letters'        => %w[🇦 🇧 🇨 🇩 🇪 🇫 🇬 🇭 🇮 🇯 🇰 🇱 🇲 🇳 🇴 🇵 🇶 🇷 🇸 🇹],
        'food'           => %w[🍎 🍍 🍇 🥐 🥗 🥪 🍕 🥓 🍜 🥘 🍧 🍩 🍰 🍬 🍭 ☕ 🧃 🍵 🍾 🍸],
        'faces'          => %w[😄 😋 😎 😂 🥰 😎 🤔 🙄 😑 🤨 😮 😴 😛 😤 🤑 😭 😨 🥵 🥶 😷],
        'animals'        => %w[🐔 🐴 🐸 🐷 🐗 🐰 🐹 🦊 🐶 🐼 🦓 🐁 🐘 🐢 🐍 🐳 🦐 🐠 🦢 🦜],
        'transportation' => %w[🚗 🚓 🚌 🚚 🚜 🚅 🚋 🚇 🚠 ✈ 🚁 🚀 🚢 🛹 🚲 🛴 🛵 🚑 🚒 🦽]
      }

      def self.exec(context, args)
        options = args[:options].split(',')
        raise Classes::ExecutionError.new(nil, "vous devez spécifier un maximum de vingt options afin de créer le sondage. Ceci est une limitation de Discord quant à la quantité de réactions que peut contenir un seul message. Si vous souhaitez davantage d'options, créez d'autres sondages à la suite.") if options.length > 20

        context.message.delete

        layout = OPTIONS[args[:type]]
        raise Classes::ExecutionError.new(nil, "le type de réactions est incorrect. Faites `105:commands` pour voir la liste des réactions possibles.") if layout.nil?

        emojis = layout[0..(options.length - 1)]
        description = ''
        options.each.with_index do |option, index|
          description << "#{emojis[index]} #{option}\n"
        end

        message = context.send_embed('', Utils.embed(
          title: ":bar_chart: Sondage : #{args[:name]}",
          description: description.chomp,
          author: Discordrb::Webhooks::EmbedAuthor.new(
            name: context.author.display_name,
            icon_url: context.author.avatar_url
          )
        ))
        emojis.each do |emoji|
          message.react(emoji)
        end
      end
    end
  end
end
