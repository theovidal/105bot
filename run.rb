require 'discordrb'
require 'sequel'
require 'psych'
require 'date'
require 'timeloop'

require_relative 'lib/utils'
require_relative 'lib/data'

DB = Sequel.sqlite(HundredFive::CONFIG['db']['path'])

require_relative 'core'

client = Discordrb::Bot.new(
  token: HundredFive::CONFIG['bot']['token'],
  log_mode: HundredFive::CONFIG['bot']['debug'] ? :debug : :quiet,
  name: HundredFive::CONFIG['meta']['name'],
  client_id: HundredFive::CONFIG['meta']['client_id']
)

connected = false

$bot = HundredFive::Bot.new(client)

client.message(start_with: HundredFive::CONFIG['bot']['prefix']) do |event|
  args = event.content.sub(' ', ',').gsub("\n", '\\n').split(',')
  command_name = args[0].delete_prefix(HundredFive::CONFIG['bot']['prefix'])
  $bot.handle_command(command_name, args[1..], event)
end

client.ready do
  Discordrb::LOGGER.info("Client running")
  client.game = HundredFive::CONFIG['meta']['status']
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
