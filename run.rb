require 'discordrb'
require 'sequel'
require 'psych'

config_file = File.dirname(__FILE__) + '/data/config.yml'
raise StandardError, 'The config.yml configuration file is required in the data folder' unless File::exist?(config_file)
$config = Psych.load(File.read(config_file))

subjects_file = File.dirname(__FILE__) + '/data/subjects.yml'
raise StandardError, 'The subjects.yml configuration file is required in the data folder' unless File::exist?(subjects_file)
$subjects = Psych.load(File.read(subjects_file))

DB = Sequel.sqlite($config['db']['path'])
$bot = Discordrb::Bot.new token: $config['bot']['token']

require_relative 'commands/commands'
require_relative 'commands/add'
require_relative 'commands/show'
require_relative 'commands/refresh'
require_relative 'commands/hide'
require_relative 'lib/data'
require_relative 'lib/models'

$bot.message(start_with: $config['bot']['prefix']) do |event|
  return unless event.author.role? $config['server']['role']
  return unless event.channel.id == $config['server']['commands_channel']
  parts = event.content.split(" ")[1..]
  command = parts[0]
  args = parts[1..]

  Coronagenda::Commands::LIST[command].(event, args)

  event.message.delete
end

$bot.ready do
  puts "Successfully logged in"
end

$bot.run

