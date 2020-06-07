module HundredFive
  module Commands
    class Refresh < Command
      DESC = "Rafraichir tout l'agenda visible"
      CATEGORY = 'agenda'

      def self.exec(context, _)
        waiter = Classes::Waiter.new(context)

        agenda = Models::Agendas.get(context, waiter)

        Models::Messages.from_agenda(agenda[:snowflake]).all.each do |message|
          Models::Messages.refresh(context, agenda, message)
        end
        Models::Messages.refresh_weekly(context, agenda[:snowflake])
        waiter.finish
      end
    end
  end
end
