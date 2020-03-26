require 'discordrb'
require 'sequel'
require 'psych'
require 'date'
require 'timeloop'

require_relative 'lib/storage'
require_relative 'lib/utils'

$config = load_yml('config')
$subjects = load_yml('subjects')

DB = Sequel.sqlite($config['db']['path'])

require_relative 'core'

client = Discordrb::Bot.new(
  token: $config['bot']['token'],
  log_mode: $config['bot']['debug'] ? :debug : :quiet,
  name: $config['meta']['name'],
  client_id: $config['meta']['client_id']
)

$bot = Coronagenda::Bot.new(client)

client.message(start_with: $config['bot']['prefix']) do |event|
  args = event.content.gsub("\n", '\\n').split(" ")
  command_name = args[0].delete_prefix($config['bot']['prefix'])
  $bot.handle_command(command_name, args[1..], event)
end

client.ready do
  puts "Client running"
  client.game = "#{$config['bot']['prefix']}help"
  Thread.new do
    Timeloop.every $config['bot']['refresh_interval'].second do
      Discordrb::LOGGER.debug("Sending event notifications...")
      Coronagenda::Utils.event_notification(client)
    end
  end
end

client.run
