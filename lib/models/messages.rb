module HundredFive
  module Models
    class Messages < Sequel::Model
      def self.refresh(context, agenda, message)
        assignments = Models::Assignments.from_day(agenda[:snowflake], message[:date])
        homework = ''
        events = ''

        assignments.each do |assignment|
          if assignment[:type] == 'work'
            homework << Models::Assignments.prettify(assignment)
          else
            events << Models::Assignments.prettify(assignment) unless assignment[:is_weekly]
          end
        end

        events = "*Aucun événement n'est prévu ce jour*" if events == ''
        homework = "*Aucun travail n'est à faire pour ce jour*" if homework == ''

        date = message[:date]
        day = date.day == 1 ? '1er' : date.day

        context.channel.message(message[:message]).edit('', Utils.embed(
          title: ":calendar_spiral: #{DAYS[date.wday]} #{day} #{MONTHS[date.month - 1]} #{date.year}",
          color: CONFIG['messages']['day_colors'][date.wday],
          fields: [
            Discordrb::Webhooks::EmbedField.new(
              name: ':bell: Évenements',
              value: events,
              inline: true
            ),
            Discordrb::Webhooks::EmbedField.new(
              name: ':clipboard: Travaux',
              value: homework,
              inline: true
            )
          ]
        ))
      end

      def self.refresh_weekly(context, agenda)
        model = Models::Messages.from_agenda(agenda, true).first
        msg = context.channel.message(model[:message])

        days = []
        6.times do |wday|
          events = Assignments.from_agenda(agenda, true).all.select{ |a| a[:date].wday == wday }
          next if events.length == 0

          content = ''
          events.each do |event|
            content << Assignments.prettify(event, true)
          end

          days.push(Discordrb::Webhooks::EmbedField.new(
            name: ":calendar_spiral: #{DAYS[wday]}",
            value: content
          ))
        end

        msg.edit('', Utils.embed(
          title: '🔔📌 Événements hebdomadaires',
          fields: days
        ))
      end

      def self.from_day(agenda, day)
        if day.is_a? Array
          day = Date.new(2020, day[1], day[0])
        end
        Messages.from_agenda(agenda).where(date: day).first
      end

      def self.from_agenda(agenda, weekly = false)
        Messages.where(agenda: agenda, weekly: weekly)
      end

      def self.delete_many(context, agenda, messages)
        messages.each do |message|
          context.bot.channel(agenda[:channel]).message(message[:message]).delete
          message.delete
        end
      end
    end
  end
end
