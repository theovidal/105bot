module HundredFive
  module Models
    class Assignments < Sequel::Model
      TYPES = %w(homework event weekly_event)

      def self.prettify(assignment, weekly = false)
        subject = SUBJECTS[assignment[:subject]]
        if assignment.type == 'homework'
          due = assignment[:hour] != nil ? "(rendu avant #{assignment[:hour]}h)" : ''
        else
          due = "(à #{assignment[:hour]}h)"
        end
        output = "• #{subject['emoji']} #{subject['name']} : #{assignment[:text].gsub('\\n', "\n")} #{due}\n"
        unless assignment[:link] == nil
          output << "#{assignment[:link]}\n"
        end
        output
      end

      def self.refresh_weekly(context)
        msg = context.bot.channel(CONFIG['server']['output_channel']).message(CONFIG['server']['weekly_message'])

        days = []
        6.times do |wday|
          events = Assignments.where(is_weekly: 1).all.select{ |a| a[:date].wday == wday }
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

      def self.from_day(day)
        if day.is_a? Array
          day = Date.new(2020, day[1], day[0])
        end
        Assignments.all.select { |a| a[:date] == day }
      end

      def self.upcoming_events
        now = Time.now
        Assignments.all.select do |assignment|
          next if assignment.type == 'homework'

          date = assignment[:date]
          time = Time.new(date.year, date.month, date.day, assignment[:hour])

          if assignment.is_weekly
            next unless time.wday === now.wday
            time = Time.new(now.year, now.month, now.day, assignment[:hour])
          end

          time >= now && time <= now + CONFIG['bot']['refresh_interval']
        end
      end
    end
  end
end
