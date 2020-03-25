require_relative 'command'

module Coronagenda
  module Commands
    class Purge < Command
      DESC = 'Supprimer les devoirs et événements passés'
      USAGE = 'purge'

      def self.exec(context, _)
        waiter = Classes::Waiter.new(context, ":pirate_flag: Retrait des jours passés, veuillez patienter...")

        messages = Models::Messages.all.select { |m| m[:date] < Date.today }
        messages.each do |message|
          context.bot.channel($config['server']['output_channel']).message(message[:discord_id]).delete
          message.delete
          Models::Assignments.from_day(message[:date]).each { |a| a.delete }
        end

        waiter.edit(":white_check_mark: Retrait des jours passés effectué.")
      end
    end
  end
end
