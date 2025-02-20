require 'sequel'
require 'date'
require 'main'
require 'snowflake-rb'

require_relative 'lib/data'
require_relative 'lib/utils'

unless File.file?(HundredFive::CONFIG['db']['path'])
  File.new(HundredFive::CONFIG['db']['path'], 'w+')
end

DB = Sequel.sqlite(HundredFive::CONFIG['db']['path'])
SF = Snowflake::Rb.snowflake(1, 1)

require_relative 'core'

      require 'discordrb'
      require 'timeloop'

      client = Discordrb::Bot.new(
        token: ENV['DISCORD_TOKEN'],
        log_mode: HundredFive::CONFIG['bot']['debug'] ? :debug : :quiet,
        name: HundredFive::CONFIG['meta']['name'],
        client_id: HundredFive::CONFIG['meta']['client_id']
      )

      connected = false

      $bot = HundredFive::Bot.new(client)

      client.message(start_with: HundredFive::CONFIG['bot']['prefix']) do |event|
        message = event.content.delete_prefix(HundredFive::CONFIG['bot']['prefix']).gsub("\n", '\\n')
        $bot.handle_command(event, message)
      end

      client.ready do
        Discordrb::LOGGER.info("Connected as #{client.profile.name}")
        client.update_status(
          'online',
          HundredFive::CONFIG['meta']['status'],
          nil,
          0,
          false,
          HundredFive::CONFIG['meta']['status_type']
        )
        connected = true
      end

      Thread.new do
        Timeloop.every HundredFive::CONFIG['bot']['refresh_interval'].second do
          if connected
            Discordrb::LOGGER.debug('Sending event notifications...')
            notifications_number = HundredFive::Utils.event_notification(client)
            Discordrb::LOGGER.debug("Sended #{notifications_number} notifications about upcoming events.")
          else
            Discordrb::LOGGER.debug("Bot isn't connected - don't check for events")
          end
        end
      end

      client.run
