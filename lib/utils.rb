module HundredFive
  module Utils
    # Generate a Discord embed
    #
    # @param title [String] Embed's title
    # @param description [String] Text to display in the embed
    # @param url [String] URL the user can click on
    # @param author [Discordrb::Webhooks::EmbedAuthor] Embed's author
    # @param thumbnail [Discordrb::Webhooks::EmbedThumbnail] Little image to display on the side
    # @param image [Discordrb::Webhooks::EmbedImage] Big image to display on top of the embed
    # @param timestamp [Time] Embed's time
    # @param footer [Discordrb::Webhooks::EmbedFooter] Embed's footer
    # @param fields [Array<Discordrb::Webhooks::EmbedField>] Embed's fields, with title and value
    def Utils.embed(title: nil,
                    description: nil,
                    url: nil,
                    color: CONFIG['messages']['color'].to_i,
                    author: nil,
                    thumbnail: nil,
                    image: nil,
                    timestamp: Time.now,
                    footer: Discordrb::Webhooks::EmbedFooter.new(
                      text: "#{CONFIG['meta']['name']} v#{CONFIG['meta']['version']}",
                      icon_url: CONFIG['meta']['illustration']
                    ),
                    fields: [])
      Discordrb::Webhooks::Embed.new(
        title: title,
        color: color,
        description: description,
        url: url,
        fields: fields,
        author: author,
        thumbnail: thumbnail,
        image: image,
        timestamp: timestamp,
        footer: footer
      )
    end

    def Utils.event_notification(client)
      events = Models::Assignments.upcoming_events
      unless events == []
        events.each do |event|
          subject = SUBJECTS[event[:subject]]
          role = client.server(689125786460094548).role(subject['role'])
          client.channel(CONFIG['server']['broadcast_channel']).send_embed(role.mention, Utils.embed(
            title: ':bell: Un événement va débuter',
            url: event[:link],
            color: role.color.combined,
            description: "#{subject['emoji']} #{subject['name']} : #{event.text.gsub('\\n', "\n")}",
            thumbnail: Discordrb::Webhooks::EmbedThumbnail.new(
              url: subject['illustration']
            )
          ))
        end
      end
      events.size
    end
  end
end
