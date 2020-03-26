require 'discordrb'
require 'sequel'
require 'psych'
require 'date'
require 'timeloop'

require_relative 'lib/utils'
require_relative 'lib/data'

DB = Sequel.sqlite(Coronagenda::CONFIG['db']['path'])

require_relative 'core'

client = Discordrb::Bot.new(
  token: Coronagenda::CONFIG['bot']['token'],
  log_mode: Coronagenda::CONFIG['bot']['debug'] ? :debug : :quiet,
  name: Coronagenda::CONFIG['meta']['name'],
  client_id: Coronagenda::CONFIG['meta']['client_id']
)

$bot = Coronagenda::Bot.new(client)

client.message(start_with: Coronagenda::CONFIG['bot']['prefix']) do |event|
  args = event.content.gsub("\n", '\\n').split(" ")
  command_name = args[0].delete_prefix(Coronagenda::CONFIG['bot']['prefix'])
  $bot.handle_command(command_name, args[1..], event)
end

client.ready do
  puts "Client running"
  client.game = "#{Coronagenda::CONFIG['bot']['prefix']}help"
  Thread.new do
    Timeloop.every Coronagenda::CONFIG['bot']['refresh_interval'].second do
      Discordrb::LOGGER.debug("Sending event notifications...")
      Coronagenda::Utils.event_notification(client)
    end
  end
end

client.run
