module HundredFive
  module Models
    class Assignments < Sequel::Model
      TYPES = %w(work event weekly_event)

      def self.prettify(assignment, weekly = true)
        if assignment.type == 'work'
          due = assignment[:hour] == nil ? '' : "(rendu avant #{assignment[:hour]}h)"
        else
          due = "(à #{assignment[:hour]}h)"
        end
        output = "• "
        output << "#{assignment[:subject]} : " unless assignment[:subject].nil?
        output << "#{assignment[:text].gsub('\\n', "\n")} #{due}\n"
        output << "#{assignment[:link]}\n" unless assignment[:link] == nil

        output
      end

      def self.from_day(agenda, day)
        if day.is_a? Array
          day = Date.new(2020, day[1], day[0])
        end
        Assignments.from_agenda(agenda).where(date: day)
      end

      def self.from_agenda(agenda, is_weekly = false)
        Assignments.where(agenda: agenda, is_weekly: is_weekly)
      end

      def self.upcoming_events
        now = Time.now
        Assignments.all.select do |assignment|
          next if assignment[:type] == 'work'

          date = assignment[:date]
          time = Time.new(date.year, date.month, date.day, assignment[:hour])

          if assignment[:is_weekly]
            next unless time.wday === now.wday
            time = Time.new(now.year, now.month, now.day, assignment[:hour])
          end

          time >= now && time <= now + CONFIG['bot']['refresh_interval']
        end
      end
    end
  end
end
