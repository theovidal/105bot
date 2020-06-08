module HundredFive
  module Commands
    module Agenda
      class RefreshCommand < Command
        DESC = "Rafraichir tout l'agenda visible"
        CATEGORY = 'agenda'

        def self.exec(context, _)
          agenda = Models::Agendas.get(context)
          waiter = Classes::Waiter.new(context)

          Models::Messages.from_agenda(agenda[:snowflake]).all.each do |message|
            Models::Messages.refresh(context, agenda, message)
          end
          Models::Messages.refresh_weekly(context, agenda[:snowflake])
          waiter.finish
        end
      end
    end
  end
end
