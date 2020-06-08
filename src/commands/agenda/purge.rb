module HundredFive
  module Commands
    module Agenda
      class PurgeCommand < Command
        DESC = 'Supprimer les travaux et événements passés'
        CATEGORY = 'agenda'
        USAGE = 'purge'

        def self.exec(context, _)
          waiter = Classes::Waiter.new(context)

          agenda = Models::Agendas.get(context, waiter)

          messages = Models::Messages.from_agenda(agenda[:snowflake]){date < Date.today}.all
          Models::Messages.delete_many(messages, agenda)

          assignments = Models::Assignments.from_agenda(agenda[:snowflake]){date < Date.today}.all
          assignments.each { |assignment| assignment.delete }

          waiter.finish
        end
      end
    end
  end
end
