require_relative 'command'

module HundredFive
  module Commands
    class Purge < Command
      DESC = 'Supprimer les devoirs et événements passés'
      USAGE = 'purge'

      def self.exec(context, _)
        waiter = Classes::Waiter.new(context, ":pirate_flag: Retrait des devoirs et événements passés, veuillez patienter...")

        messages = Models::Messages.all.select { |m| m[:date] < Date.today }
        messages.each do |message|
          context.bot.channel(CONFIG['server']['output_channel']).message(message[:discord_id]).delete
          message.delete
        end

        assignments = Models::Assignments.all.select { |a| a[:date] < Date.today }
        assignments.each { |assignment| assignment.delete }

        waiter.finish("Retrait des devoirs et événements passés effectué.")
      end
    end
  end
end
