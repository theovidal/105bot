module Coronagenda
  module Models
    class Assignments < Sequel::Model
      def self.prettify(assignment)
        subject = $subjects[assignment[:subject]]
        emoji = ":#{subject['emoji']}:"
        if assignment.type == 'homework'
          due = assignment[:hour] != nil ? "(rendu avant #{assignment[:hour]}h)" : ''
        else
          due = "(à #{assignment[:hour]}h)"
        end
        output = "• #{emoji} #{subject['name']} : #{assignment[:text].gsub('\\n', "\n")} #{due}\n"
        unless assignment[:link] == nil
          output << "#{assignment[:link]}\n"
        end
        output
      end

      def self.from_day(day)
        if day.is_a? Array
          day = Date.new(2020, day[1], day[0])
        end
        Assignments.all.select { |a| a[:date] == day }
      end
    end
  end
end
