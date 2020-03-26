module Coronagenda
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
                    author: nil,
                    thumbnail: nil,
                    image: nil,
                    timestamp: Time.now,
                    footer: Discordrb::Webhooks::EmbedFooter.new(
                      text: "#{$config['meta']['name']} v#{$config['meta']['version']}",
                      icon_url: $config['meta']['illustration']
                    ),
                    fields: [])
      Discordrb::Webhooks::Embed.new(
        title: title,
        color: $config['meta']['color'].to_i,
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
      content = ''
      events = Models::Assignments.upcoming_events
      unless events == []
        events.each do |event|
          subject = $subjects[event[:subject]]
          content << "<@&#{subject['role']}> :#{subject['emoji']}: #{subject['name']} - Événement : #{event.text}\n"
        end
        client.channel($config['server']['broadcast_channel']).send_message(content)
      end
    end
  end
end
