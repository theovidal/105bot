module HundredFive
  module Models
    class Messages < Sequel::Model
      def self.refresh(context, agenda, message)
        assignments = Models::Assignments.from_day(agenda[:snowflake], message[:date])
        homework = ''
        events = ''

        assignments.each do |assignment|
          if assignment[:type] == 'homework'
            homework << Models::Assignments.prettify(assignment)
          else
            events << Models::Assignments.prettify(assignment) unless assignment[:is_weekly]
          end
        end

        events = "*Aucun événement n'est prévu ce jour*" if events == ''
        homework = "*Aucun devoir n'est à faire pour ce jour*" if homework == ''

        date = message[:date]
        day = date.day == 1 ? '1er' : date.day

        context.channel.message(message[:message]).edit('', Utils.embed(
          title: ":calendar_spiral: #{DAYS[date.wday]} #{day} #{MONTHS[date.month - 1]} #{date.year}",
          color: CONFIG['messages']['day_colors'][date.wday],
          fields: [
            Discordrb::Webhooks::EmbedField.new(
              name: ':bell: Évenements',
              value: events
            ),
            Discordrb::Webhooks::EmbedField.new(
              name: ':clipboard: Devoirs',
              value: homework
            )
          ]
        ))
      end

      def self.from_day(agenda, day)
        if day.is_a? Array
          day = Date.new(2020, day[1], day[0])
        end
        Messages.all.select { |m| m[:date] == day && m[:agenda] == agenda }.first
      end
    end
  end
end
