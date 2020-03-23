module Coronagenda
  module Models
    class Assignments < Sequel::Model
      def self.prettify(assignment)
        date = Time.at(assignment[:date])
        subject = $subjects[assignment[:subject]]
        emoji = ":#{subject['emoji']}:"
        if assignment.type == 'homework'
          due = assignment[:to_give] ? "(rendu avant #{date.hour}h)" : ''
        else
          due = "(à #{date.hour}h)"
        end
        output = "• #{emoji} #{subject['name']} : #{assignment[:text].gsub('\\n', "\n")} #{due}\n"
        unless assignment[:link] == nil
          output << "#{assignment[:link]}\n"
        end
        output
      end

      def self.from_day(day)
        if day.is_a? Array
          day = Time.new(2020, day[1], day[0], 0)
        end
        Assignments.all.select do |a|
          date = a[:date] + TZ_OFFSET
          date >= day.to_i && date < day.to_i + 86400
        end
      end
    end
  end
end
