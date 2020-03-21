require 'discordrb'
require 'sequel'

DB = Sequel.sqlite('./testing.sqlite')
$bot = Discordrb::Bot.new token: 'NjkwOTA0ODkxOTI5MTMzMTkw.XnYrOw.LaFum0In7MgwYThi2uM4wQ2xb7w'

require_relative 'commands/commands'
require_relative 'commands/add'
require_relative 'commands/generate'
require_relative 'commands/refresh'
require_relative 'lib/data'
require_relative 'lib/models'

$bot.message(start_with: 'agenda') do |event|
  return unless event.author.role? 690904299152212039
  parts = event.content.split(" ")[1..]
  command = parts[0]
  args = parts[1..]

  Coronagenda::Commands::LIST[command].(args)

  event.message.delete
end

$bot.ready do
  Coronagenda::Commands.refresh
end

$bot.run

